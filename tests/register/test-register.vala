public class Vdi.OrderTests : TestClass {
	public OrderTests () {
		base ("order");

		this.add_test ("can-order-concrete-gobject-subclass", this.can_order_concrete_gobject_subclass);

		if (Test.undefined ()) {
			this.add_test ("cannot-order-interface", this.cannot_order_interface);
			this.add_test ("cannot-order-abstract-gobject-subclass", this.cannot_order_abstract_gobject_subclass);
			this.add_test ("cannot-order-fundamental-gtype-class", this.cannot_order_fundamental_gtype_class);
			this.add_test ("cannot-order-struct", this.cannot_order_struct);
			this.add_test ("cannot-order-primitive-type", this.cannot_order_primitive_type);
		}
	}

	private void can_order_concrete_gobject_subclass () {
		Test.summary ("Tests if the factory can order concrete GObject subclasses");

		var factory = new ObjectFactory ();
		factory.order (typeof (ConcreteGObjectSubclass));
	}

	private void cannot_order_interface () {
		Test.summary ("Tests if the factory cannot order interfaces");

		if (Test.subprocess ()) {
			var factory = new ObjectFactory ();
			factory.order (typeof (Interface));
			assert_not_reached ();
		}

		Test.trap_subprocess (null, 0, 0);
		Test.trap_assert_failed ();
		Test.trap_assert_stderr ("*CRITICAL*assertion*failed*");
	}

	private void cannot_order_abstract_gobject_subclass () {
		Test.summary ("Tests if the factory cannot order abstract GObject subclasses");

		if (Test.subprocess ()) {
			var factory = new ObjectFactory ();
			factory.order (typeof (AbstractGObjectSubclass));
			assert_not_reached ();
		}

		Test.trap_subprocess (null, 0, 0);
		Test.trap_assert_failed ();
		Test.trap_assert_stderr ("*CRITICAL*assertion*failed*");
	}

	private void cannot_order_fundamental_gtype_class () {
		Test.summary ("Tests if the factory cannot order fundamental GType classes");

		if (Test.subprocess ()) {
			var factory = new ObjectFactory ();
			factory.order (typeof (FundamentalGTypeClass));
			assert_not_reached ();
		}

		Test.trap_subprocess (null, 0, 0);
		Test.trap_assert_failed ();
		Test.trap_assert_stderr ("*CRITICAL*assertion*failed*");
	}

	private void cannot_order_struct () {
		Test.summary ("Tests if the factory cannot order structs");

		if (Test.subprocess ()) {
			var factory = new ObjectFactory ();
			factory.order (typeof (Struct));
			assert_not_reached ();
		}

		Test.trap_subprocess (null, 0, 0);
		Test.trap_assert_failed ();
		Test.trap_assert_stderr ("*CRITICAL*assertion*failed*");
	}

	private void cannot_order_primitive_type () {
		Test.summary ("Tests if the factory cannot order primitive types");

		if (Test.subprocess ()) {
			var factory = new ObjectFactory ();
			factory.order (typeof (int));
			assert_not_reached ();
		}

		Test.trap_subprocess (null, 0, 0);
		Test.trap_assert_failed ();
		Test.trap_assert_stderr ("*CRITICAL*assertion*failed*");
	}
}
