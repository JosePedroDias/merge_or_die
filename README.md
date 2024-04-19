# merge or die (godot edition)

This is the simplest (lamest) port of my ludum dare entry in Rust/Comfy to Godot.

# TODO

- stretch goal: persist highest score, present it at start and completed game
- stretch goal: move/scale matched tile
- stretch goal: particle effect when penalty
- stretch goal: scale up new cells

# test on web

Project > Export
Export Project

on the terminal:

    cd web
    caddy run

visit https://localhost/

# COI fixes

- download this [coi-serviceworker](https://raw.githubusercontent.com/gzuidhof/coi-serviceworker/master/coi-serviceworker.js)
- add it to the exported page's head `<script src="coi-serviceworker.js"></script>`
