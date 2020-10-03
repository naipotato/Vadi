# Vadi

![Continuous Integration](https://github.com/nahuelwexd/Vadi/workflows/Continuous%20Integration/badge.svg)
[![codecov](https://codecov.io/gh/nahuelwexd/Vadi/branch/main/graph/badge.svg)](https://codecov.io/gh/nahuelwexd/Vadi)

Vadi is an IoC Container developed in order to facilitate the usage of dependency injection for Vala
developers, but it can be used on any GObject-compatible language, with more or less syntax
facilities.

## Build & Install

Vadi requires the following dependencies:

- `glib-2.0` (>= 2.54)
- `gobject-2.0` (>= 2.54)
- `gee-0.8`
- `meson`
- `vala`

Once installed, run the following commands:

```sh
meson build --buildtype release --prefix /usr
sudo ninja -C build install
```

## Usage

In order to use Vadi, you need to declare your dependencies as public construct or construct-only
properties:

```vala
public class Client : Object {

    public Service service { get; construct; }
}
```

If you need to specify the concrete classes to use when initializing these dependencies, you can do
so by registering them in the container.

```vala
// By using register_type (), you're telling the container to use the second argument as type to
// instantiate any construct property that matches the type of the first argument.
container.register_type (typeof (Service), typeof (FoodService));

// You can use register_factory (), if you have specific steps in order to instantiate a dependency,
// or if you want to use a constructor instead of letting the container solve using the construct
// properties
container.register_factory (typeof (Service), container => {
    return new FoodService (container.resolve (typeof (Database)));
});

// Finally, if all you want is for the container to return an instance you already have pre-built,
// you can use register_instance () to pass it to it
container.register_instance (typeof (Service), a_prebuilt_service);
```

Then, all you need to do is to run `resolve ()` and that's it:

```
var app = container.resolve (typeof (App));
app.run ();
```

## License

This library is licensed under the [GNU Lesser General Public License v3](COPYING.LESSER) or any
later version.
