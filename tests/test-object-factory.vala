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

class NoGObjectDependency {}
interface MyInterfaceDependency : GLib.Object {}
abstract class MyAbstractDependency : GLib.Object, MyInterfaceDependency {}
class MyDependency : MyAbstractDependency {}

class MyService : GLib.Object
{
	public MyInterfaceDependency my_interface_dependency { get; construct; }
	public MyAbstractDependency my_abstract_dependency { get; construct; }
	public MyDependency my_dependency { get; construct; }


	public MyService (MyDependency my_dependency)
	{
		GLib.Object (
			my_dependency: my_dependency
		);
	}
}

int main (string[] args)
{
	GLib.Test.init (ref args);

	GLib.Test.add_func ("/vadi/object-factory/order/interface", () => {
		if (GLib.Test.subprocess ())
		{
			var factory = new Vdi.ObjectFactory ();
			factory.order (typeof (MyInterfaceDependency));
		}

		GLib.Test.trap_subprocess (null, 0, 0);
		GLib.Test.trap_assert_failed ();
		GLib.Test.trap_assert_stderr ("*CRITICAL*assertion*failed*");
	});

	GLib.Test.add_func ("/vadi/object-factory/order/abstract", () => {
		if (GLib.Test.subprocess ())
		{
			var factory = new Vdi.ObjectFactory ();
			factory.order (typeof (MyAbstractDependency));
		}

		GLib.Test.trap_subprocess (null, 0, 0);
		GLib.Test.trap_assert_failed ();
		GLib.Test.trap_assert_stderr ("*CRITICAL*assertion*failed*");
	});

	GLib.Test.add_func ("/vadi/object-factory/order/primitive-type", () => {
		if (GLib.Test.subprocess ())
		{
			var factory = new Vdi.ObjectFactory ();
			factory.order (typeof (int));
		}

		GLib.Test.trap_subprocess (null, 0, 0);
		GLib.Test.trap_assert_failed ();
		GLib.Test.trap_assert_stderr ("*CRITICAL*assertion*failed*");
	});

	GLib.Test.add_func ("/vadi/object-factory/order/no-gobject", () => {
		if (GLib.Test.subprocess ())
		{
			var factory = new Vdi.ObjectFactory ();
			factory.order (typeof (NoGObjectDependency));
		}

		GLib.Test.trap_subprocess (null, 0, 0);
		GLib.Test.trap_assert_failed ();
		GLib.Test.trap_assert_stderr ("*CRITICAL*assertion*failed*");
	});

	GLib.Test.add_func ("/vadi/object-factory/order-with-alias/primitive-alias-type", () => {
		if (GLib.Test.subprocess ())
		{
			var factory = new Vdi.ObjectFactory ();
			factory.order_with_alias (typeof (int), typeof (MyDependency));
		}

		GLib.Test.trap_subprocess (null, 0, 0);
		GLib.Test.trap_assert_failed ();
		GLib.Test.trap_assert_stderr ("*CRITICAL*assertion*failed*");
	});

	GLib.Test.add_func ("/vadi/object-factory/order-with-alias/no-gobject-alias", () => {
		if (GLib.Test.subprocess ())
		{
			var factory = new Vdi.ObjectFactory ();
			// FIXME: Maybe I need a subclass of NoGObjectDependency?
			factory.order_with_alias (typeof (NoGObjectDependency), typeof (NoGObjectDependency));
		}

		GLib.Test.trap_subprocess (null, 0, 0);
		GLib.Test.trap_assert_failed ();
		GLib.Test.trap_assert_stderr ("*CRITICAL*assertion*failed*");
	})

	GLib.Test.add_func ("/vadi/object-factory/order-with-alias/alias-object-dont-match", () => {
		if (GLib.Test.subprocess ())
		{
			var factory = new Vdi.ObjectFactory ();
			factory.order_with_alias (typeof (MyService), typeof (MyDependency));
		}

		GLib.Test.trap_subprocess (null, 0, 0);
		GLib.Test.trap_assert_failed ();
		GLib.Test.trap_assert_stderr ("*CRITICAL*assertion*failed*");
	});

	GLib.Test.add_func ("/vadi/object-factory/order-with-alias/object-interface", () => {
		if (GLib.Test.subprocess ())
		{
			var factory = new Vdi.ObjectFactory ();
			factory.order_with_alias (typeof (MyInterfaceDependency), typeof (MyInterfaceDependency));
		}

		GLib.Test.trap_subprocess (null, 0, 0);
		GLib.Test.trap_assert_failed ();
		GLib.Test.trap_assert_stderr ("*CRITICAL*assertion*failed*");
	});

	GLib.Test.add_func ("/vadi/object-factory/order-with-alias/object-abstract", () => {
		if (GLib.Test.subprocess ())
		{
			var factory = new Vdi.ObjectFactory ();
			factory.order_with_alias (typeof (MyInterfaceDependency), typeof (MyAbstractDependency));
		}

		GLib.Test.trap_subprocess (null, 0, 0);
		GLib.Test.trap_assert_failed ();
		GLib.Test.trap_assert_stderr ("*CRITICAL*assertion*failed*");
	});

	GLib.Test.add_func ("/vadi/object-factory/order-with-recipe/primitive-type", () => {
		if (GLib.Test.subprocess ())
		{
			var factory = new Vdi.ObjectFactory ();
			factory.order_with_recipe (typeof (int), container => {
				return new MyDependency ();
			});
		}

		GLib.Test.trap_subprocess (null, 0, 0);
		GLib.Test.trap_assert_failed ();
		GLib.Test.trap_assert_stderr ("*CRITICAL*assertion*failed*");
	});

	GLib.Test.add_func ("/vadi/object-factory/withdraw/non-ordered-interface", () => {
		var factory = new Vdi.ObjectFactory ();

		GLib.Object? dependency = factory.withdraw (typeof (MyInterfaceDependency));

		GLib.assert_null (dependency);
	});

	GLib.Test.add_func ("/vadi/object-factory/withdraw/non-ordered-abstract-object", () => {
		var factory = new Vdi.ObjectFactory ();

		GLib.Object? dependency = factory.withdraw (typeof (MyAbstractDependency));

		GLib.assert_null (dependency);
	});

	GLib.Test.add_func ("/vadi/object-factory/withdraw/non-ordered-object", () => {
		var factory = new Vdi.ObjectFactory ();

		GLib.Object? dependency = factory.withdraw (typeof (MyDependency));

		GLib.assert_null (dependency);
	});

	GLib.Test.add_func ("/vadi/object-factory/withdraw/ordered-object", () => {
		var factory = new Vdi.ObjectFactory ();
		factory.order (typeof (MyDependency));

		GLib.Object? dependency = factory.withdraw (typeof (MyDependency));

		GLib.assert_nonnull (dependency);
		GLib.assert (dependency is MyDependency);
	});

	return GLib.Test.run ();
}
