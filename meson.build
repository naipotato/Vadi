project ('vadi', 'c', 'vala',
    license: 'LGPL-3.0-or-later',
    version: '0.1.0'
)

glib_min_version = '2.54'

add_project_arguments (
    '--hide-internal',
    '--target-glib=@0@'.format (glib_min_version),
    language: 'vala'
)

glib_dep = dependency ('glib-2.0', version: '>= @0@'.format (glib_min_version))
gobject_dep = dependency ('gobject-2.0', version: '>= @0@'.format (glib_min_version))
gee_dep = dependency ('gee-0.8')

subdir ('lib')

if get_option ('tests')
    subdir ('tests')
endif
