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

public delegate T Vadi.ContainerFactoryFunc<T> (Vadi.Container container);

// This is highly inspired on libgee's internal reimplementation of GClosure
// https://gitlab.gnome.org/GNOME/libgee/-/blob/master/gee/functions.vala
[CCode (simple_generics = true)]
private class Vadi.ContainerFactoryFuncClosure<T> : GLib.Object {
	public ContainerFactoryFunc<T> func;

	public ContainerFactoryFuncClosure(owned ContainerFactoryFunc<T> func) {
		this.func = (owned) func;
	}
}
