public struct Vdi.Struct {
	// Dummy field 'cause Vala structs cannot be empty
	int dummy;
}

public class Vdi.FundamentalGTypeClass {}

public interface Vdi.Interface : Object {}
public class Vdi.ConcreteGObjectSubclass : Object, Interface {}

public abstract class Vdi.AbstractGObjectSubclass : Object {}
