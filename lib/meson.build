sources = [
	'container.vala',
	'factory-func-closure.vala',
]

vadi_version       = meson.project_version()
version_array      = vadi_version.split('.')
vadi_major_version = version_array[0]
vadi_minor_version = version_array[1]
vadi_micro_version = version_array[2]

vadi_api_version = vadi_major_version + '.0'
vadi_api_name    = meson.project_name() + '-' + vadi_api_version
vadi_gi_name     = 'Vadi-' + vadi_api_version

vadi_header  = meson.project_name() + '.h'
vadi_vapi    = vadi_api_name + '.vapi'
vadi_pc      = vadi_api_name + '.pc'
vadi_deps    = vadi_api_name + '.deps'
vadi_gir     = vadi_gi_name + '.gir'
vadi_typelib = vadi_gi_name + '.typelib'

deps = [
	dependency('glib-2.0', version: '>=2.64'),
	dependency('gobject-2.0', version: '>=2.64'),
]

vadi = library(meson.project_name(), sources,
     vala_header: vadi_header,
       vala_vapi: vadi_vapi,
        vala_gir: vadi_gir,
    dependencies: deps,
         install: true,
     install_dir: [true, true, true, true]
)

g_ir_compiler = find_program('g-ir-compiler')

custom_target(vadi_typelib,
	command: [
		g_ir_compiler,
		'--shared-library',
		vadi.full_path(),
		'--output',
		'@OUTPUT@',
		meson.current_build_dir() / vadi_gir
  ],
	     output: vadi_typelib,
	    depends: vadi,
	    install: true,
	install_dir: get_option('libdir') / 'girepository-1.0'
)

vadi_dep = declare_dependency(
	          link_with: vadi,
	       dependencies: deps,
	include_directories: [include_directories('.')]
)

pkg = import('pkgconfig')

pkg.generate(vadi,
	description: 'IoC Container for Vala',
	   filebase: vadi_api_name,
	        url: 'https://github.com/nahuelwexd/Vadi'
)

install_data('deps.meson',
	install_dir: get_option('datadir') / 'vala/vapi',
	     rename: vadi_deps,
)
