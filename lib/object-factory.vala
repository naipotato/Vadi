public class Vdi.ObjectFactory {
	private GenericArray<Order> _orders = new GenericArray<Order> ();

	public unowned Order order (Type type_to_order) requires (type_to_order.is_object ()) {
		var order = new Order (type_to_order);
		unowned Order result = order;

		this._orders.add (order);

		return result;
	}

	public Object? pick_up (Type type_to_pick_up) {
		uint registration_index;
		bool type_is_registered = this._orders.find_custom<Type> (type_to_pick_up, (registration, type) => {
			return registration.ordered_type.is_a (type);
		}, out registration_index);

		if (!type_is_registered)
			return null;

		Order order = this._orders[registration_index];
		ParamSpec[] construct_props = this.get_construct_props_from_type (order.ordered_type);

		string[] names;
		Value[] values;
		this.initialize_props (construct_props, out names, out values);

		return Object.new_with_properties (order.ordered_type, names, values);
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

	private void initialize_props (ParamSpec[] props, out string[] names, out Value[] values) {
		var names_array = new GenericArray<string> ();
		var values_array = new Array<Value> ();

		foreach (ParamSpec pspec in props) {
			Object prop_value = this.pick_up (pspec.value_type);
			if (prop_value != null) {
				names_array.add (pspec.name);

				var @value = Value (pspec.value_type);
				@value.set_object (prop_value);
				values_array.append_val (@value);
			}
		}

		names = names_array.steal ();
		values = values_array.steal ();
	}
}
