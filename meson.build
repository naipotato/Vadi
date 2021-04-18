project('vadi', 'c', 'vala',
	license: 'LGPL-3.0-or-later',
	version: '1.0.0',
)

vapidir = meson.source_root () / 'vapi'

add_project_arguments('--hide-internal', '--enable-checking', '--abi-stability', '--vapidir', vapidir,
	language: 'vala'
)

subdir('lib')

if get_option('tests')
	subdir('tests')
endif
