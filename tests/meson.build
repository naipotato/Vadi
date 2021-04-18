test_container_sources = [
	'register/test-register-with-factory.vala',
	'register/test-register-with-instance.vala',
	'register/test-register.vala',

	'resolve/test-resolve.vala',

	'test-class.vala',
	'test-container.vala',
	'test-data.vala',
]

test_container = executable('test-container', test_container_sources,
	dependencies: vadi_dep
)

test('test-container', test_container)
