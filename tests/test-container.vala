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

    Test.add_func ("/vadi/container/resolve/iface", () => {
        var container = new Vadi.Container ();

        var service = container.resolve (typeof (Service));

        assert_null (service);
    });

    Test.add_func ("/vadi/container/register/none", () => {
        var container = new Vadi.Container ();

        var service = container.resolve (typeof (FoodService));

        assert_nonnull (service);
        assert_true (service.get_type ().is_a (typeof (FoodService)));
    });

    Test.add_func ("/vadi/container/register/type/simple", () => {
        var container = new Vadi.Container ();

        container.register_type (typeof (Service), typeof (FoodService));

        var service = (Service) container.resolve (typeof (Service));

        assert_nonnull (service);
        assert_true (service.get_type ().is_a (typeof (FoodService)));
    });

    Test.add_func ("/vadi/container/register/type/simple-repeat", () => {
        var container = new Vadi.Container ();

        container.register_type (typeof (Service), typeof (FoodService));

        var serviceA = (Service) container.resolve (typeof (Service));
        var serviceB = (Service) container.resolve (typeof (Service));

        assert_nonnull (serviceA);
        assert_nonnull (serviceB);
        assert_true (serviceA.get_type ().is_a (typeof (FoodService)));
        assert_true (serviceB.get_type ().is_a (typeof (FoodService)));

        assert_true (serviceA == serviceB);
    });

    Test.add_func ("/vadi/container/register/type/recursive", () => {
        var container = new Vadi.Container ();

        container.register_type (typeof (Service), typeof (FoodService));

        var client = container.resolve (typeof (Client));

        assert_nonnull (client);
        assert_nonnull (((Client) client).service);
        assert_true (((Client) client).service.get_type ().is_a (typeof (FoodService)));
    });

    Test.add_func ("/vadi/container/register/type/register-myself", () => {
        var container = new Vadi.Container ();

        container.register_type (typeof (Service), typeof (FoodService));
        container.register_type (typeof (Client), typeof (Client));

        var client = container.resolve (typeof (Client));

        assert_nonnull (client);
        assert_nonnull (((Client) client).service);
        assert_true (((Client) client).service.get_type ().is_a (typeof (FoodService)));
    });

    Test.add_func ("/vadi/container/register/factory/simple", () => {
        var container = new Vadi.Container ();

        container.register_factory (typeof (Service), container => {
            return new FoodService ();
        });

        var service = (Service) container.resolve (typeof (Service));

        assert_nonnull (service);
        assert_true (service.get_type ().is_a (typeof (FoodService)));
    });

    Test.add_func ("/vadi/container/register/factory/recursive", () => {
        var container = new Vadi.Container ();

        container.register_factory (typeof (Service), container => {
            return new FoodService ();
        });
        container.register_factory (typeof (Client), container => {
            return new Client ((Service) container.resolve (typeof (Service)));
        });

        var client = container.resolve (typeof (Client));

        assert_nonnull (client);
        assert_nonnull (((Client) client).service);
        assert_true (((Client) client).service.get_type ().is_a (typeof (FoodService)));
    });

    Test.add_func ("/vadi/container/register/instance/simple", () => {
        var container = new Vadi.Container ();
        var food_service = new FoodService ();

        container.register_instance (typeof (Service), food_service);

        var service = container.resolve (typeof (Service));

        assert_nonnull (service);
        assert_true (service == food_service);
    });

    Test.add_func ("/vadi/container/register/mixed/type-factory", () => {
        var container = new Vadi.Container ();

        container.register_type (typeof (Service), typeof (FoodService));
        container.register_factory (typeof (Client), container => {
            return new Client ((Service) container.resolve (typeof (Service)));
        });

        var client = container.resolve (typeof (Client));

        assert_nonnull (client);
        assert_nonnull (((Client) client).service);
        assert_true (((Client) client).service.get_type ().is_a (typeof (FoodService)));
    });

    Test.add_func ("/vadi/container/register/mixed/factory-type", () => {
        var container = new Vadi.Container ();

        container.register_factory (typeof (Service), container => {
            return new FoodService ();
        });

        var client = container.resolve (typeof (Client));

        assert_nonnull (client);
        assert_nonnull (((Client) client).service);
        assert_true (((Client) client).service.get_type ().is_a (typeof (FoodService)));
    });

    Test.add_func ("/vadi/container/register/mixed/instance-type", () => {
        var container = new Vadi.Container ();
        var food_service = new FoodService ();

        container.register_instance (typeof (Service), food_service);

        var client = container.resolve (typeof (Client));

        assert_nonnull (client);
        assert_nonnull (((Client) client).service);
        assert_true (((Client) client).service == food_service);
    });

    Test.add_func ("/vadi/container/register/mixed/instance-factory", () => {
        var container = new Vadi.Container ();
        var food_service = new FoodService ();

        container.register_instance (typeof (Service), food_service);
        container.register_factory (typeof (Client), container => {
            return new Client ((Service) container.resolve (typeof (Service)));
        });

        var client = container.resolve (typeof (Client));

        assert_nonnull (client);
        assert_nonnull (((Client) client).service);
        assert_true (((Client) client).service == food_service);
    });

    return Test.run ();
}
