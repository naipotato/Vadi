public delegate void Vdi.TestMethod ();

private class Vdi.Adaptor {
	private TestClass _test_class;
	private TestMethod _test_method;

	public string name { get; }

	public Adaptor (string name, owned TestMethod test_method, TestClass test_class) {
		this._name = name;
		this._test_method = (owned) test_method;
		this._test_class = test_class;
	}

	public void run (void* fixture) {
		this._test_method ();
	}

	public void set_up (void* fixture) {
		this._test_class.set_up ();
	}

	public void tear_down (void* fixture) {
		this._test_class.tear_down ();
	}
}

public abstract class Vdi.TestClass {
	private GenericArray<Adaptor> _adaptors = new GenericArray<Adaptor> ();

	public TestSuite suite { get; }

	protected TestClass (string name) {
		this._suite = new TestSuite (name);
	}

	public void add_test (string name, owned TestMethod test_method) {
		var adaptor = new Adaptor (name, (owned) test_method, this);
		this._adaptors.add (adaptor);

		this.suite.add (new TestCase (adaptor.name, adaptor.set_up, adaptor.run, adaptor.tear_down));
	}

	public virtual void set_up () {}
	public virtual void tear_down () {}
}
