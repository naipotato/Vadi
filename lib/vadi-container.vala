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

[CCode (has_target = false)]
public delegate Object Vadi.ContainerFactoryFunc (Container container);

public class Vadi.Container : Object {

    /* Private fields */

    private Gee.Map<Type, Type> _types;
    private Gee.Map<Type, ContainerFactoryFunc> _factories;
    private Gee.Map<Type, Object> _instances;

    /* End private fields */


    /* GObject blocks */

    construct {
        this._types = new Gee.HashMap<Type, Type> ();
        this._factories = new Gee.HashMap<Type, ContainerFactoryFunc> ();
        this._instances = new Gee.HashMap<Type, Object> ();
    }

    /* End GObject blocks */


    /* Public methods */

    public void register_type (Type key_type, Type value_type)
        requires (key_type.is_interface () || key_type.is_object ())
        requires (value_type.is_object ())
        requires (value_type.is_a (key_type))
    {
        this._types[key_type] = value_type;
    }

    public void register_factory (Type key_type, ContainerFactoryFunc container_factory)
        requires (key_type.is_interface () || key_type.is_object ())
    {
        this._factories[key_type] = container_factory;
    }

    public void register_instance (Type key_type, Object instance)
        requires (key_type.is_interface () || key_type.is_object ())
        requires (instance.get_type ().is_a (key_type))
    {
        this._instances[key_type] = instance;
    }

    public Object? resolve (Type type) requires (type.is_interface () || type.is_object ()) {
        if (this._instances.has_key (type)) {
            return this._instances[type];
        }

        if (this._factories.has_key (type)) {
            var factory = this._factories[type];
            this._instances[type] = factory (this);
            return this._instances[type];
        }

        var resolve_type = this._types.has_key (type) ? this._types[type] : type;

        if (resolve_type.is_object ()) {
            var props = this.get_construct_properties (resolve_type);
            var names = this.get_matched_property_names (props);
            var values = this.get_matched_property_values (props);

            this._instances[type] = Object.new_with_properties (resolve_type, names, values);
            return this._instances[type];
        }

        return null;
    }

    /* End public methods */


    /* Private methods */

    private (unowned ParamSpec)[] get_construct_properties (Type type) {
        var klass = (ObjectClass) type.class_ref ();
        var props = klass.list_properties ();
        (unowned ParamSpec)[] result = new (unowned ParamSpec)[0];

        for (var i = 0; i < props.length; i++) {
            if ((props[i].flags & ParamFlags.CONSTRUCT) != 0 ||
            (props[i].flags & ParamFlags.CONSTRUCT_ONLY) != 0)
            {
                result.resize (result.length + 1);
                result[result.length - 1] = props[i];
            }
        }

        return result;
    }

    private (unowned string)[] get_matched_property_names ((unowned ParamSpec)[] props) {
        (unowned string)[] names = new (unowned string)[0];

        for (var i = 0; i < props.length; i++) {
            foreach (var key_type in this._instances.keys) {
                if (props[i].value_type == key_type) {
                    names.resize (names.length + 1);
                    names[names.length - 1] = props[i].name;
                }
            }

            foreach (var key_type in this._factories.keys) {
                if (props[i].value_type == key_type) {
                    names.resize (names.length + 1);
                    names[names.length - 1] = props[i].name;
                }
            }

            foreach (var key_type in this._types.keys) {
                if (props[i].value_type == key_type) {
                    names.resize (names.length + 1);
                    names[names.length - 1] = props[i].name;
                }
            }
        }

        return names;
    }

    private Value[] get_matched_property_values ((unowned ParamSpec)[] props) {
        Value[] values = new Value[0];

        for (var i = 0; i < props.length; i++) {
            foreach (var key_type in this._instances.keys) {
                if (props[i].value_type == key_type) {
                    values.resize (values.length + 1);
                    var @value = Value (key_type);
                    @value.set_object (this.resolve (key_type));
                    values[values.length - 1] = @value;
                }
            }

            foreach (var key_type in this._factories.keys) {
                if (props[i].value_type == key_type) {
                    values.resize (values.length + 1);
                    var @value = Value (key_type);
                    @value.set_object (this.resolve (key_type));
                    values[values.length - 1] = @value;
                }
            }

            foreach (var key_type in this._types.keys) {
                if (props[i].value_type == key_type) {
                    values.resize (values.length + 1);
                    var @value = Value (key_type);
                    @value.set_object (this.resolve (key_type));
                    values[values.length - 1] = @value;
                }
            }
        }

        return values;
    }

    /* End private methods */
}
