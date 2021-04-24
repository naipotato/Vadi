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

public delegate Object Vadi.FactoryFunc (Vadi.Container container);

// This is highly inspired on libgee's internal reimplementation of GClosure
// https://gitlab.gnome.org/GNOME/libgee/-/blob/master/gee/functions.vala
private class Vadi.FactoryFuncClosure : Object {
	public FactoryFunc func;

	public FactoryFuncClosure(owned FactoryFunc func) {
		this.func = (owned) func;
	}
}
