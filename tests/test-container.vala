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

interface Service : Object {}

class FoodService : Service, Object {}

class Client : Object {
	public Service service { get; construct; }

	public Client (Service service) {
		Object (
			service: service
		);
	}
}

int main (string[] args) {
	Test.init (ref args);

	Test.add_func ("/vadi/container/resolve/interface", () => {
		var container = new Vadi.Container ();

		Object service = container.resolve (typeof (Service));

		assert_null (service);
	});

	Test.add_func ("/vadi/container/register/none", () => {
		var container = new Vadi.Container ();

		Object service = container.resolve (typeof (FoodService));

		assert_nonnull (service);
	});

	Test.add_func ("/vadi/container/register/type/simple", () => {
		var container = new Vadi.Container ();

		container.register_type (typeof (Service), typeof (FoodService));

		Object service = container.resolve (typeof (Service));

		assert_nonnull (service);
		assert_true (service is FoodService);
	});

	Test.add_func ("/vadi/container/register/type/simple-repeat", () => {
		var container = new Vadi.Container ();

		container.register_type (typeof (Service), typeof (FoodService));

		Object service_a = container.resolve (typeof (Service));
		Object service_b = container.resolve (typeof (Service));

		assert_nonnull (service_a);
		assert_nonnull (service_b);
		assert_true (service_a is FoodService);
		assert_true (service_b is FoodService);

		assert_true (service_a == service_b);
	});

	Test.add_func ("/vadi/container/register/type/recursive", () => {
		var container = new Vadi.Container ();

		container.register_type (typeof (Service), typeof (FoodService));

		var client = (Client) container.resolve (typeof (Client));

		assert_nonnull (client);
		assert_nonnull (client.service);
		assert_true (client.service is FoodService);
	});

	Test.add_func ("/vadi/container/register/type/register-myself", () => {
		var container = new Vadi.Container ();

		container.register_type (typeof (Service), typeof (FoodService));
		container.register_type (typeof (Client), typeof (Client));

		var client = (Client) container.resolve (typeof (Client));

		assert_nonnull (client);
		assert_nonnull (client.service);
		assert_true (client.service is FoodService);
	});

	Test.add_func ("/vadi/container/register/factory/simple", () => {
		var container = new Vadi.Container ();

		container.register_factory (typeof (Service), container => {
			return new FoodService ();
		});

		Object service = container.resolve (typeof (Service));

		assert_nonnull (service);
		assert_true (service is FoodService);
	});

	Test.add_func ("/vadi/container/register/factory/recursive", () => {
		var container = new Vadi.Container ();

		container.register_factory (typeof (Service), container => {
			return new FoodService ();
		});
		container.register_factory (typeof (Client), container => {
			return new Client ((Service) container.resolve (typeof (Service)));
		});

		var client = (Client) container.resolve (typeof (Client));

		assert_nonnull (client);
		assert_nonnull (client.service);
		assert_true (client.service is FoodService);
	});

	Test.add_func ("/vadi/container/register/factory/use-local-variables", () => {
		var container = new Vadi.Container ();
		var food_service = new FoodService ();

		container.register_factory (typeof (Client), container => {
			return new Client (food_service);
		});

		var client = (Client) container.resolve (typeof (Client));

		assert_nonnull (client);
		assert_nonnull (client.service);
		assert_true (client.service == food_service);
	});

	Test.add_func ("/vadi/container/register/instance/simple", () => {
		var container = new Vadi.Container ();
		var food_service = new FoodService ();

		container.register_instance (typeof (Service), food_service);

		Object service = container.resolve (typeof (Service));

		assert_nonnull (service);
		assert_true (service == food_service);
	});

	Test.add_func ("/vadi/container/register/mixed/type-factory", () => {
		var container = new Vadi.Container ();

		container.register_type (typeof (Service), typeof (FoodService));
		container.register_factory (typeof (Client), container => {
			return new Client ((Service) container.resolve (typeof (Service)));
		});

		var client = (Client) container.resolve (typeof (Client));

		assert_nonnull (client);
		assert_nonnull (client.service);
		assert_true (client.service is FoodService);
	});

	Test.add_func ("/vadi/container/register/mixed/factory-type", () => {
		var container = new Vadi.Container ();

		container.register_factory (typeof (Service), container => {
			return new FoodService ();
		});

		var client = (Client) container.resolve (typeof (Client));

		assert_nonnull (client);
		assert_nonnull (client.service);
		assert_true (client.service is FoodService);
	});

	Test.add_func ("/vadi/container/register/mixed/instance-type", () => {
		var container = new Vadi.Container ();
		var food_service = new FoodService ();

		container.register_instance (typeof (Service), food_service);

		var client = (Client) container.resolve (typeof (Client));

		assert_nonnull (client);
		assert_nonnull (client.service);
		assert_true (client.service == food_service);
	});

	Test.add_func ("/vadi/container/register/mixed/instance-factory", () => {
		var container = new Vadi.Container ();
		var food_service = new FoodService ();

		container.register_instance (typeof (Service), food_service);
		container.register_factory (typeof (Client), container => {
			return new Client ((Service) container.resolve (typeof (Service)));
		});

		var client = (Client) container.resolve (typeof (Client));

		assert_nonnull (client);
		assert_nonnull (client.service);
		assert_true (client.service == food_service);
	});

	return Test.run ();
}
