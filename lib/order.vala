public class Vdi.Order {
	public Type ordered_type { get; }

	internal Order (Type type) {
		this._ordered_type = type;
	}
}
