project('vadi', 'vala', 'c',
	license: 'LGPL-3.0-or-later',
	version: '0.1.0',
)

add_project_arguments('--hide-internal', '--enable-checking', '--abi-stability',
	language: 'vala',
)

subdir('lib')

if get_option('tests')
	subdir('tests')
endif
