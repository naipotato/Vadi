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
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          default = pkgs.stdenv.mkDerivation rec {
            name = "vadi";
            src = self;
            outputs = [ "out" "dev" ];

            enableParallelBuilding = true;
            nativeBuildInputs = with pkgs; [ meson ninja pkg-config vala gobject-introspection ];
            buildInputs = with pkgs; [ glib libgee ];

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
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              meson
              ninja
              pkg-config
              vala
              glib
							libgee
							gobject-introspection
            ];
          };
        });
    };
}
