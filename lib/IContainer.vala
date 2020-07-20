/* Vadi - An IoC Container for Vala
 * Copyright (C) 2020 Nahuel Gomez Castro <nahual_gomca@outlook.com.ar>
 *
 * Vadi is free software: you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Vadi is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General
 * Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this program.  If not, see
 * <https://www.gnu.org/licenses/>.
 */

public interface Vadi.IContainer : Object {

    public abstract void register_type (Type key_type, Type value_type);
    public abstract void register_factory (Type key_type, ContainerFactoryFunc container_factory);
    public abstract void register_instance (Type key_type, Object instance);
    public abstract Object? resolve (Type type);
}
