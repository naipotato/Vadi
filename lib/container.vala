/* Copyright 2020 Nahuel Gomez Castro <nahual_gomca@outlook.com.ar>
 *
 * This file is part of Vadi.
 *
 * Vadi is free software: you can redistribute it and/or modify it under the
 * terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option)
 * any later version.
 *
 * Vadi is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with Vadi. If not, see <https://www.gnu.org/licenses/>.
 */

public class Vadi.Container : Object {
	private Gee.Map<Type, Type>               _types;
	private Gee.Map<Type, FactoryFuncClosure> _factories;
	private Gee.Map<Type, Object>             _instances;

	public void bind_type (Type key_type, Type value_type)
		requires (key_type.is_interface () || key_type.is_object ())
		requires (value_type.is_object ())
		requires (value_type.is_a (key_type))
	{
		this._types[key_type] = value_type;
	}

	public void bind_factory (Type key_type, owned FactoryFunc container_factory)
		requires (key_type.is_interface () || key_type.is_object ())
	{
		this._factories[key_type] = new FactoryFuncClosure ((owned) container_factory);
	}

	public void bind_instance (Type key_type, Object instance)
		requires (key_type.is_interface () || key_type.is_object ())
		requires (instance.get_type ().is_a (key_type))
	{
		this._instances[key_type] = instance;
	}

	public new Object? @get (Type type) requires (type.is_interface () || type.is_object ()) {
		if (this._instances.has_key (type)) {
			return this._instances[type];
		}

		if (this._factories.has_key (type)) {
			this._instances[type] = (Object) this._factories[type].func (this);

			return this._instances[type];
		}

		Type resolve_type = this._types.has_key (type) ? this._types[type] : type;

		if (resolve_type.is_object ()) {
			ParamSpec[] props = this.get_construct_props_from_type (resolve_type);

			(unowned string)[] names = this.get_matched_property_names (props);
			Value[] values           = this.get_matched_property_values (props);

			this._instances[type] = Object.new_with_properties (resolve_type, names, values);

			return this._instances[type];
		}

		return null;
	}

	private ParamSpec[] get_construct_props_from_type (Type type) {
		var object_class = (ObjectClass) type.class_ref ();
		ParamSpec[] props = object_class.list_properties ();

		var construct_props_array = new GenericArray<ParamSpec> ();

		foreach (ParamSpec pspec in props) {
			if ((pspec.flags & ParamFlags.CONSTRUCT) != 0 || (pspec.flags & ParamFlags.CONSTRUCT_ONLY) != 0)
				construct_props_array.add (pspec);
		}

		return construct_props_array.steal ();
	}

	private (unowned string)[] get_matched_property_names (ParamSpec[] props) {
		var names = new (unowned string)[0];

		for (var i = 0; i < props.length; i++) {
			foreach (Type key_type in this._instances.keys) {
				if (props[i].value_type == key_type) {
					names.resize (names.length + 1);
					names[names.length - 1] = props[i].name;
				}
			}

			foreach (Type key_type in this._factories.keys) {
				if (props[i].value_type == key_type) {
					names.resize (names.length + 1);
					names[names.length - 1] = props[i].name;
				}
			}

			foreach (Type key_type in this._types.keys) {
				if (props[i].value_type == key_type) {
					names.resize (names.length + 1);
					names[names.length - 1] = props[i].name;
				}
			}
		}

		return names;
	}

	private Value[] get_matched_property_values (ParamSpec[] props) {
		var values = new Value[0];

		for (var i = 0; i < props.length; i++) {
			foreach (Type key_type in this._instances.keys) {
				if (props[i].value_type == key_type) {
					values.resize (values.length + 1);

					var @value = Value (key_type);
					@value.set_object (this.@get (key_type));

					values[values.length - 1] = @value;
				}
			}

			foreach (Type key_type in this._factories.keys) {
				if (props[i].value_type == key_type) {
					values.resize (values.length + 1);

					var @value = Value (key_type);
					@value.set_object (this.@get (key_type));

					values[values.length - 1] = @value;
				}
			}

			foreach (Type key_type in this._types.keys) {
				if (props[i].value_type == key_type) {
					values.resize (values.length + 1);

					var @value = Value (key_type);
					@value.set_object (this.@get (key_type));

					values[values.length - 1] = @value;
				}
			}
		}

		return values;
	}

	construct {
		this._types     = new Gee.HashMap<Type, Type> ();
		this._factories = new Gee.HashMap<Type, FactoryFuncClosure> ();
		this._instances = new Gee.HashMap<Type, Object> ();
	}
}
