{
  description = "An IoC Container for Vala";

  outputs = { self, nixpkgs, ... }:
    let
      supportedSystems = [
        "aarch64-linux"
        "i686-linux"
        "riscv64-linux"
        "x86_64-linux"
        "x86_64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

			packagesFor = forAllSystems (system:
				let
					pkgs = nixpkgsFor.${system};
				in with pkgs; rec {
          nativeBuildInputs = [ meson ninja pkg-config vala gobject-introspection ];
          buildInputs = [ glib libgee ];
					propagatedBuildInputs = buildInputs;
				});
    in
    {
      packages = forAllSystems (system:
        let
					pkgs = nixpkgsFor.${system};
					packages = packagesFor.${system};
        in
        {
          default = pkgs.stdenv.mkDerivation rec {
            name = "vadi";
            src = self;
            outputs = [ "out" "dev" ];

            enableParallelBuilding = true;
						inherit (packages) nativeBuildInputs buildInputs propagatedBuildInputs;

            meta = with pkgs.lib; {
              homepage = "https://github.com/nahuelwexd/Vadi";
              license = with licenses; [ lgpl3Only ];
              maintainers = [ "Tristan Ross" "Nahu" ];
            };
          };
        });

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
					packages = packagesFor.${system};
        in
        {
          default = pkgs.mkShell {
						packages = packages.nativeBuildInputs ++ packages.buildInputs;
          };
        });
    };
}
