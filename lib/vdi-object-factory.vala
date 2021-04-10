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
 * A generic factory of {@link Object}s.
 *
 * The idea of this factory is that you can "order" {@link Object}s, and then
 * proceed to "withdraw" them already created, with their dependencies already
 * resolved. Dependencies must be construct or construct-only properties. You
 * can read more about construct and construct-only properties
 * [[https://wiki.gnome.org/Projects/Vala/Tutorial#GObject-Style_Construction|here]].
 *
 * You can also set "recipes" where you can instruct the factory on how to
 * create the {@link Object}s.
 *
 * ''Note:'' {@link Object}s dependencies also have to be ordered at the
 * factory for them to be supplied.
 *
 * ''Example:'' //Basic usage//
 * {{{
 * class MyDependency : Object
 * {
 *     public void do_work ()
 *     {
 *         print ("Doing some work\n");
 *     }
 * }
 *
 * class MyService : Object
 * {
 *     public MyDependency my_dependency { get; construct; }
 *
 *     public MyService (MyDependency my_dependency)
 *     {
 *         Object (my_dependency: my_dependency);
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
public class Vdi.ObjectFactory : Object
{
	private HashTable<Type, Object>                _instance_map;
	private HashTable<Type, Vdi.RecipeFuncClosure> _recipe_map;
	private HashTable<Type, Type>                  _type_map;


	/**
	 * Instructs this factory to create the {@link Object} specified in
	 * ``object_type``.
	 *
	 * @see order_with_alias
	 * @see order_with_recipe
	 *
	 * @param object_type The {@link Type} of the {@link Object} to be created.
	 * @return ``true`` if the {@link Object} could be ordered, ``false``
	 *         otherwise.
	 */
	public bool order (Type object_type)
		requires (object_type.is_object ())
		requires (!object_type.is_abstract ())
	{
		if (this._type_map.contains (object_type))
			return false;

		this._type_map[object_type] = object_type;

		return true;
	}

	/**
	 * Similar to {@link order}, with the difference that it allows you to alias
	 * the {@link Object}.
	 *
	 * @see order
	 * @see order_with_recipe
	 *
	 * @param alias_type The {@link Type} that will be used as an alias to
	 *                   create the {@link Object}.
	 * @param object_type The {@link Type} of the {@link Object} to be created.
	 * @return ``true`` if the {@link Object} could be ordered, ``false``
	 *         otherwise.
	 */
	public bool order_with_alias (Type alias_type, Type object_type)
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
	 * Similar to {@link order}, but now you can set a recipe function that will
	 * be used to create the {@link Object}.
	 *
	 * @see order
	 * @see order_with_alias
	 *
	 * @param object_type The {@link Type} of the {@link Object} to be created.
	 * @param recipe The recipe that will be used to create the
	 *               {@link Object}.
	 * @return ``true`` if the {@link Object} could be ordered, ``false``
	 *         otherwise.
	 */
	public bool order_with_recipe (Type object_type, owned Vdi.RecipeFunc recipe)
		requires (object_type.is_object () || object_type.is_interface ())
	{
		if (this._recipe_map.contains (object_type))
			return false;

		this._recipe_map[object_type] = new Vdi.RecipeFuncClosure ((owned) recipe);

		return true;
	}

	/**
	 * Returns the {@link Object} specified in ``object_type``, only if it was
	 * previously ordered.
	 *
	 * @param object_type The {@link Type} of the {@link Object} to be withdrawn.
	 * @return The specified {@link Object} if it was previously ordered,
	 *         ``null`` otherwise.
	 */
	public Object? withdraw (Type object_type)
	{
		if (this._instance_map.contains (object_type))
			return this._instance_map[object_type];

		if (this._recipe_map.contains (object_type))
		{
			this._instance_map[object_type] = this._recipe_map[object_type].func (this);

			return this._instance_map[object_type];
		}

		if (this._type_map.contains (object_type))
		{
			Type real_type = this._type_map[object_type];
			(unowned ParamSpec)[] construct_properties = this.get_construct_properties (real_type);

			string[] names;
			Value[] values;
			this.initialize_properties (construct_properties, out names, out values);

			this._instance_map[object_type] = Object.new_with_properties (object_type, names, values);

			return this._instance_map[object_type];
		}

		return null;
	}


	private (unowned ParamSpec)[] get_construct_properties (Type type)
	{
		var object_class = (ObjectClass) type.class_ref ();
		(unowned ParamSpec)[] properties = object_class.list_properties ();

		var construct_properties = new (unowned ParamSpec)[0];

		for (var i = 0; i < properties.length; i++)
		{
			if ((properties[i].flags & ParamFlags.CONSTRUCT) != 0 ||
				(properties[i].flags & ParamFlags.CONSTRUCT_ONLY) != 0)
			{
				construct_properties += properties[i];
			}
		}

		return construct_properties;
	}

	private void initialize_properties ((unowned ParamSpec)[] properties,
	                                    out string[] names,
	                                    out Value[] values)
	{
		names = new string[0];
		values = new Value[0];

		for (var i = 0; i < properties.length; i++)
		{
			Object? property_value = this.withdraw (properties[i].value_type);
			if (property_value != null)
			{
				names.resize (names.length + 1);
				names[names.length - 1] = properties[i].name;

				values.resize (values.length + 1);
				values[values.length - 1] = Value (properties[i].value_type);
				values[values.length - 1].set_object (property_value);
			}
		}
	}


	construct
	{
		this._instance_map = new HashTable<Type, Object> (direct_hash, direct_equal);
		this._recipe_map   = new HashTable<Type, Vdi.RecipeFuncClosure> (direct_hash, direct_equal);
		this._type_map     = new HashTable<Type, Type> (direct_hash, direct_equal);
	}
}
