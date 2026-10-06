all:
	valac --pkg libsoup-3.0 --pkg json-glib-1.0 *.vala */*.vala

C:
	valac -C --pkg libsoup-3.0 --pkg json-glib-1.0 *.vala */*.vala

nix:
	nix-shell --run make

start:
	./FouineShell

startnix:
	nix-shell --run ./FouineShell