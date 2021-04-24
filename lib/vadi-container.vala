/* Vadi - An IoC Container for Vala
 * Copyright (C) 2020 Nahuel Gomez Castro <nahual_gomca@outlook.com.ar>
 *
 * Vadi is free software: you can redistribute it and/or modify it under the
 * terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option)
 * any later version.
 *
 * Vadi is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for
 * more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

public class Vadi.Container : Object {
	private Gee.Map<Type, Type>               _types;
	private Gee.Map<Type, FactoryFuncClosure> _factories;
	private Gee.Map<Type, Object>             _instances;

	public void register_type<K, V> ()
		requires (typeof (K).is_interface () || typeof (K).is_object ())
		requires (typeof (V).is_object ())
		requires (typeof (V).is_a (typeof (K)))
	{
		this._types[typeof (K)] = typeof (V);
	}

	public void register_factory<K> (owned FactoryFunc<K> container_factory)
		requires (typeof (K).is_interface () || typeof (K).is_object ())
	{
		this._factories[typeof (K)] = new FactoryFuncClosure<K> ((owned) container_factory);
	}

	public void register_instance<K> (K instance)
		requires (typeof (K).is_interface () || typeof (K).is_object ())
		requires (instance is K)
	{
		this._instances[typeof (K)] = (Object) instance;
	}

	public T? resolve<T> () requires (typeof (T).is_interface () || typeof (T).is_object ()) {
		return this.resolve_type (typeof (T));
	}

	private (unowned ParamSpec)[] get_construct_properties (Type type) {
		var klass = (ObjectClass) type.class_ref ();
		(unowned ParamSpec)[] props = klass.list_properties ();

		var result = new (unowned ParamSpec)[0];

		for (var i = 0; i < props.length; i++) {
			if ((props[i].flags & ParamFlags.CONSTRUCT) != 0 || (props[i].flags & ParamFlags.CONSTRUCT_ONLY) != 0) {
				result.resize (result.length + 1);
				result[result.length - 1] = props[i];
			}
		}

		return result;
	}

	private (unowned string)[] get_matched_property_names ((unowned ParamSpec)[] props) {
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

	private Value[] get_matched_property_values ((unowned ParamSpec)[] props) {
		var values = new Value[0];

		for (var i = 0; i < props.length; i++) {
			foreach (Type key_type in this._instances.keys) {
				if (props[i].value_type == key_type) {
					values.resize (values.length + 1);

					var @value = Value (key_type);
					@value.set_object (this.resolve_type (key_type));

					values[values.length - 1] = @value;
				}
			}

			foreach (Type key_type in this._factories.keys) {
				if (props[i].value_type == key_type) {
					values.resize (values.length + 1);

					var @value = Value (key_type);
					@value.set_object (this.resolve_type (key_type));

					values[values.length - 1] = @value;
				}
			}

			foreach (Type key_type in this._types.keys) {
				if (props[i].value_type == key_type) {
					values.resize (values.length + 1);

					var @value = Value (key_type);
					@value.set_object (this.resolve_type (key_type));

					values[values.length - 1] = @value;
				}
			}
		}

		return values;
	}

	private Object? resolve_type (Type type) {
		if (this._instances.has_key (type)) {
			return this._instances[type];
		}

		if (this._factories.has_key (type)) {
			this._instances[type] = (Object) this._factories[type].func (this);

			return this._instances[type];
		}

		Type resolve_type = this._types.has_key (type) ? this._types[type] : type;

		if (resolve_type.is_object ()) {
			(unowned ParamSpec)[] props = this.get_construct_properties (resolve_type);

			(unowned string)[] names = this.get_matched_property_names (props);
			Value[] values           = this.get_matched_property_values (props);

			this._instances[type] = Object.new_with_properties (resolve_type, names, values);

			return this._instances[type];
		}

		return null;
	}

	construct {
		this._types     = new Gee.HashMap<Type, Type> ();
		this._factories = new Gee.HashMap<Type, FactoryFuncClosure> ();
		this._instances = new Gee.HashMap<Type, Object> ();
	}
}
