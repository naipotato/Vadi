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

/**
 * A function used by {@link Vdi.ObjectFactory.order_with_recipe}.
 *
 * It will be called when it's necessary to create the {@link GLib.Object}.
 *
 * @see Vdi.ObjectFactory.order_with_recipe
 *
 * @param object_factory The {@link Vdi.ObjectFactory} instance that called
 *                       this function.
 * @return The {@link GLib.Object} created.
 */
public delegate GLib.Object Vdi.RecipeFunc (Vdi.ObjectFactory object_factory);

// This is highly inspired on libgee's internal reimplementation of GClosure
// https://gitlab.gnome.org/GNOME/libgee/-/blob/master/gee/functions.vala
[CCode (simple_generics = true)]
private class Vdi.RecipeFuncClosure : GLib.Object
{
    public RecipeFunc func;


    public RecipeFuncClosure(owned RecipeFunc func)
    {
        this.func = (owned) func;
    }
}
