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

interface Service : GLib.Object {}

class FoodService : Service, GLib.Object {}

class Client : GLib.Object
{
    /* Public properties */

    public Service service { get; construct; }

    /* End public properties */


    /* Public constructors */

    public Client (Service service)
    {
        GLib.Object (
            service: service
        );
    }

    /* End public constructors */
}

int main (string[] args)
{
    GLib.Test.init (ref args);

    GLib.Test.add_func ("/vadi/container/resolve/iface", () => {
        var container = new Vadi.Container ();

        GLib.Object service = container.resolve (typeof (Service));

        GLib.assert_null (service);
    });

    GLib.Test.add_func ("/vadi/container/register/none", () => {
        var container = new Vadi.Container ();

        GLib.Object service = container.resolve (typeof (FoodService));

        GLib.assert_nonnull (service);
        GLib.assert_true (service.get_type ().is_a (typeof (FoodService)));
    });

    GLib.Test.add_func ("/vadi/container/register/type/simple", () => {
        var container = new Vadi.Container ();

        container.register_type (typeof (Service), typeof (FoodService));

        GLib.Object service = container.resolve (typeof (Service));

        GLib.assert_nonnull (service);
        GLib.assert_true (service.get_type ().is_a (typeof (FoodService)));
    });

    GLib.Test.add_func ("/vadi/container/register/type/simple-repeat", () => {
        var container = new Vadi.Container ();

        container.register_type (typeof (Service), typeof (FoodService));

        GLib.Object service_a = container.resolve (typeof (Service));
        GLib.Object service_b = container.resolve (typeof (Service));

        GLib.assert_nonnull (service_a);
        GLib.assert_nonnull (service_b);
        GLib.assert_true (service_a.get_type ().is_a (typeof (FoodService)));
        GLib.assert_true (service_b.get_type ().is_a (typeof (FoodService)));

        GLib.assert_true (service_a == service_b);
    });

    GLib.Test.add_func ("/vadi/container/register/type/recursive", () => {
        var container = new Vadi.Container ();

        container.register_type (typeof (Service), typeof (FoodService));

        GLib.Object client = container.resolve (typeof (Client));

        GLib.assert_nonnull (client);
        GLib.assert_nonnull (((Client) client).service);
        GLib.assert_true (((Client) client).service.get_type ().is_a (typeof (FoodService)));
    });

    GLib.Test.add_func ("/vadi/container/register/type/register-myself", () => {
        var container = new Vadi.Container ();

        container.register_type (typeof (Service), typeof (FoodService));
        container.register_type (typeof (Client), typeof (Client));

        GLib.Object client = container.resolve (typeof (Client));

        GLib.assert_nonnull (client);
        GLib.assert_nonnull (((Client) client).service);
        GLib.assert_true (((Client) client).service.get_type ().is_a (typeof (FoodService)));
    });

    GLib.Test.add_func ("/vadi/container/register/factory/simple", () => {
        var container = new Vadi.Container ();

        container.register_factory<Service> (container => {
            return new FoodService ();
        });

        GLib.Object service = (Service) container.resolve (typeof (Service));

        GLib.assert_nonnull (service);
        GLib.assert_true (service.get_type ().is_a (typeof (FoodService)));
    });

    GLib.Test.add_func ("/vadi/container/register/factory/recursive", () => {
        var container = new Vadi.Container ();

        container.register_factory<Service> (container => {
            return new FoodService ();
        });
        container.register_factory<Client> (container => {
            return new Client ((Service) container.resolve (typeof (Service)));
        });

        GLib.Object client = container.resolve (typeof (Client));

        GLib.assert_nonnull (client);
        GLib.assert_nonnull (((Client) client).service);
        GLib.assert_true (((Client) client).service.get_type ().is_a (typeof (FoodService)));
    });

    GLib.Test.add_func ("/vadi/container/register/instance/simple", () => {
        var container = new Vadi.Container ();
        var food_service = new FoodService ();

        container.register_instance (typeof (Service), food_service);

        GLib.Object service = container.resolve (typeof (Service));

        GLib.assert_nonnull (service);
        GLib.assert_true (service == food_service);
    });

    GLib.Test.add_func ("/vadi/container/register/mixed/type-factory", () => {
        var container = new Vadi.Container ();

        container.register_type (typeof (Service), typeof (FoodService));
        container.register_factory<Client> (container => {
            return new Client ((Service) container.resolve (typeof (Service)));
        });

        GLib.Object client = container.resolve (typeof (Client));

        GLib.assert_nonnull (client);
        GLib.assert_nonnull (((Client) client).service);
        GLib.assert_true (((Client) client).service.get_type ().is_a (typeof (FoodService)));
    });

    GLib.Test.add_func ("/vadi/container/register/mixed/factory-type", () => {
        var container = new Vadi.Container ();

        container.register_factory<Service> (container => {
            return new FoodService ();
        });

        GLib.Object client = container.resolve (typeof (Client));

        GLib.assert_nonnull (client);
        GLib.assert_nonnull (((Client) client).service);
        GLib.assert_true (((Client) client).service.get_type ().is_a (typeof (FoodService)));
    });

    GLib.Test.add_func ("/vadi/container/register/mixed/instance-type", () => {
        var container = new Vadi.Container ();
        var food_service = new FoodService ();

        container.register_instance (typeof (Service), food_service);

        GLib.Object client = container.resolve (typeof (Client));

        GLib.assert_nonnull (client);
        GLib.assert_nonnull (((Client) client).service);
        GLib.assert_true (((Client) client).service == food_service);
    });

    GLib.Test.add_func ("/vadi/container/register/mixed/instance-factory", () => {
        var container = new Vadi.Container ();
        var food_service = new FoodService ();

        container.register_instance (typeof (Service), food_service);
        container.register_factory<Client> (container => {
            return new Client ((Service) container.resolve (typeof (Service)));
        });

        GLib.Object client = container.resolve (typeof (Client));

        GLib.assert_nonnull (client);
        GLib.assert_nonnull (((Client) client).service);
        GLib.assert_true (((Client) client).service == food_service);
    });

    return GLib.Test.run ();
}
