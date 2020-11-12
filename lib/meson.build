sources = files (
	'vdi-object-factory.vala',
	'vdi-recipe-func-closure.vala',
)

vadi_version = meson.project_version ()
version_array = vadi_version.split ('.')
vadi_major_version = version_array[0].to_int ()
vadi_minor_version = version_array[1].to_int ()
vadi_micro_version = version_array[2].to_int ()

vadi_api_version = '@0@.0'.format (vadi_major_version)
vadi_api_name = '@0@-@1@'.format (meson.project_name (), vadi_api_version)

vadi_header = '@0@.h'.format (meson.project_name ())
vadi_vapi = '@0@.vapi'.format (vadi_api_name)
vadi_pc = '@0@.pc'.format (vadi_api_name)
vadi_deps = '@0@.deps'.format (vadi_api_name)

deps = [
    glib_dep,
    gobject_dep
]

vadi = library (
    meson.project_name (),
    sources,

     vala_header: vadi_header,
       vala_vapi: vadi_vapi,
    dependencies: deps,
         install: true,
     install_dir: [true, true, true]
)

vadi_dep = declare_dependency (
              link_with: vadi,
           dependencies: deps,
    include_directories: [include_directories ('.')]
)

pkg = import ('pkgconfig')

pkg.generate (vadi,
    description: 'IoC Container for Vala',
       filebase: vadi_api_name,
            url: 'https://github.com/nahuelwexd/Vadi'
)

requires = []

foreach dep : deps
    requires += dep.name ()
endforeach

deps_conf = configuration_data ()
deps_conf.set ('deps', '\n'.join (requires))

configure_file (
            input: 'deps.meson',
           output: vadi_deps,
    configuration: deps_conf,
          install: true,
      install_dir: get_option ('datadir') / 'vala/vapi'
)
