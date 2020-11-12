/* libvadi - Dependency injection utilities for Vala.
 * Copyright 2020 Nahuel Gomez Castro <nahual_gomca@outlook.com.ar>
 *
 * libvadi is free software: you can redistribute it and/or modify it under the
 * terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option)
 * any later version.
 *
 * libvadi is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for
 * more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with libvadi.  If not, see <https://www.gnu.org/licenses/>.
 */

/**
 * A generic factory of {@link GLib.Object}s.
 *
 * The idea of this factory is that you can "order" {@link GLib.Object}s, and
 * then proceed to "withdraw" them already created, with their dependencies
 * already resolved. Dependencies must be construct or construct-only
 * properties. You can read more about construct and construct-only properties
 * [[https://wiki.gnome.org/Projects/Vala/Tutorial#GObject-Style_Construction|here]].
 *
 * You can also set "recipes" where you can instruct the factory on how to
 * create the {@link GLib.Object}s.
 *
 * ''Note:'' {@link GLib.Object}s dependencies also have to be ordered at the
 * factory for them to be supplied.
 *
 * ''Example:'' //Basic usage//
 * {{{
 * class MyDependency : GLib.Object
 * {
 *     public void do_work ()
 *     {
 *         GLib.print ("Doing some work\n");
 *     }
 * }
 *
 * class MyService : GLib.Object
 * {
 *     public MyDependency my_dependency { get; construct; }
 *
 *     public MyService (MyDependency my_dependency)
 *     {
 *         GLib.Object (
 *             my_dependency: my_dependency
 *         );
 *     }
 *
 *     public void do_something ()
 *     {
 *         this.my_dependency.do_work ();
 *     }
 * }
 *
 * void main ()
 * {
 *     // Create a new factory:
 *     var factory = new Vdi.ObjectFactory ();
 *
 *     // Order MyService and its dependency:
 *     factory.order (typeof (MyDependency));
 *     factory.order (typeof (MyService));
 *
 *     // Withdraw the service and use it:
 *     var service = (MyService) factory.withdraw (typeof (MyService));
 *     service.do_something (); // Output: ``Doing some work``
 * }
 * }}}
 *
 * ``valac --pkg vadi-0.0 vadi-basic-sample.vala``
 */
public class Vdi.ObjectFactory : GLib.Object
{
	private GLib.HashTable<GLib.Type, GLib.Object>       _instance_map;
	private GLib.HashTable<GLib.Type, RecipeFuncClosure> _recipe_map;
	private GLib.HashTable<GLib.Type, GLib.Type>         _type_map;


	/**
	 * Instructs this factory to create the {@link GLib.Object} specified in
	 * ``object_type``.
	 *
	 * @see Vdi.ObjectFactory.order_with_alias
	 * @see Vdi.ObjectFactory.order_with_recipe
	 *
	 * @param object_type The {@link GLib.Type} of the {@link GLib.Object} to
	 *                    be created.
	 * @return ``true`` if the {@link GLib.Object} could be ordered, ``false``
	 *         otherwise.
	 */
	public bool order (GLib.Type object_type)
		requires (object_type.is_object ())
		requires (!object_type.is_abstract ())
	{
		if (this._type_map.contains (object_type))
			return false;

		this._type_map[object_type] = object_type;

		return true;
	}

	/**
	 * Similar to {@link Vdi.ObjectFactory.order}, with the difference that it
	 * allows you to alias the {@link GLib.Object}.
	 *
	 * @see Vdi.ObjectFactory.order
	 * @see Vdi.ObjectFactory.order_with_recipe
	 *
	 * @param alias_type The {@link GLib.Type} that will be used as an alias to
	 *                   create the {@link GLib.Object}.
	 * @param object_type The {@link GLib.Type} of the {@link GLib.Object} to
	 *                    be created.
	 * @return ``true`` if the {@link GLib.Object} could be ordered, ``false``
	 *         otherwise.
	 */
	public bool order_with_alias (GLib.Type alias_type, GLib.Type object_type)
		requires (alias_type.is_object () || alias_type.is_interface ())
		requires (object_type.is_a (alias_type))
		requires (object_type.is_object ())
		requires (!object_type.is_abstract ())
	{
		if (this._type_map.contains (alias_type))
			return false;

		this._type_map[alias_type] = object_type;

		return true;
	}

	/**
	 * Similar to {@link Vdi.ObjectFactory.order}, but now you can set a recipe
	 * function that will be used to create the object.
	 *
	 * @see Vdi.ObjectFactory.order
	 * @see Vdi.ObjectFactory.order_with_alias
	 *
	 * @param object_type The {@link GLib.Type} of the {@link GLib.Object} to
	 *                    be created.
	 * @param recipe The recipe that will be used to create the
	 *               {@link GLib.Object}.
	 * @return ``true`` if the {@link GLib.Object} could be ordered, ``false``
	 *         otherwise.
	 */
	public bool order_with_recipe (GLib.Type object_type, owned RecipeFunc recipe)
		requires (object_type.is_object () || object_type.is_interface ())
	{
		if (this._recipe_map.contains (object_type))
			return false;

		this._recipe_map[object_type] = new RecipeFuncClosure ((owned) recipe);

		return true;
	}

	/**
	 * Returns the {@link GLib.Object} specified in ``object_type``, only if it
	 * was previously ordered.
	 *
	 * @param object_type The {@link GLib.Type} of the {@link GLib.Object} to
	 *                    be withdrawn.
	 * @return The specified {@link GLib.Object} if it was previously ordered,
	 *         ``null`` otherwise.
	 */
	public GLib.Object? withdraw (GLib.Type object_type)
	{
		if (this._instance_map.contains (object_type))
			return this._instance_map[object_type];

		if (this._recipe_map.contains (object_type))
		{
			this._instance_map[object_type] = (GLib.Object) this._recipe_map[object_type].func (this);

			return this._instance_map[object_type];
		}

		if (this._type_map.contains (object_type))
		{
			GLib.Type real_type = this._type_map[object_type];
			(unowned GLib.ParamSpec)[] construct_properties = this.get_construct_properties (real_type);

			(unowned string)[] names;
			GLib.Value[] values;
			this.initialize_properties (construct_properties, out names, out values);

			this._instance_map[object_type] = GLib.Object.new_with_properties (object_type, names, values);

			return this._instance_map[object_type];
		}

		return null;
	}


	private (unowned GLib.ParamSpec)[] get_construct_properties (GLib.Type type)
	{
		var object_class = (GLib.ObjectClass) type.class_ref ();
		(unowned GLib.ParamSpec)[] properties = object_class.list_properties ();

		var construct_properties = new (unowned GLib.ParamSpec)[0];

		for (var i = 0; i < properties.length; i++)
		{
			if ((properties[i].flags & GLib.ParamFlags.CONSTRUCT) != 0 ||
			    (properties[i].flags & GLib.ParamFlags.CONSTRUCT_ONLY) != 0)
			{
				construct_properties.resize (construct_properties.length + 1);
				construct_properties[construct_properties.length - 1] = properties[i];
			}
		}

		return construct_properties;
	}

	private void initialize_properties ((unowned GLib.ParamSpec)[] properties,
	                                    out (unowned string)[] names,
	                                    out GLib.Value[] values)
	{
		names = new (unowned string)[0];
		values = new GLib.Value[0];

		for (var i = 0; i < properties.length; i++)
		{
			GLib.Object? property_value = this.withdraw (properties[i].value_type);
			if (property_value != null)
			{
				names.resize (names.length + 1);
				names[names.length - 1] = properties[i].name;

				values.resize (values.length + 1);
				values[values.length - 1] = GLib.Value (properties[i].value_type);
				values[values.length - 1].set_object (property_value);
			}
		}
	}


	construct
	{
		this._instance_map = new GLib.HashTable<GLib.Type, GLib.Object> (GLib.int_hash, GLib.int_equal);
		this._recipe_map   = new GLib.HashTable<GLib.Type, RecipeFuncClosure> (GLib.int_hash, GLib.int_equal);
		this._type_map     = new GLib.HashTable<GLib.Type, GLib.Type> (GLib.int_hash, GLib.int_equal);
	}
}
