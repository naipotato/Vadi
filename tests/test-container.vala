int main (string[] args) {
	Test.init (ref args);

	var object_factory_suite = new TestSuite ("object-factory");
	object_factory_suite.add_suite (new Vdi.OrderTests ().suite);
	object_factory_suite.add_suite (new Vdi.RegisterWithFactoryTests ().suite);
	object_factory_suite.add_suite (new Vdi.RegisterWithInstanceTests ().suite);
	object_factory_suite.add_suite (new Vdi.ResolveTests ().suite);

	var root_suite = TestSuite.get_root ();
	root_suite.add_suite (object_factory_suite);

	return Test.run ();
}
