# Lune

A lunar phase indicator for waybar

## Usage

To use, add a snippet like the following in your waybar config
```
"custom/moonphase": {
    "exec": "lune $HOME/.local/share/moondata",
    "return-type": "json",
    "interval": 30,
    "format": "{}",
},
```

Then use the `custom/moonphase` module wherever you'd like in waybar!

## Notes

- Has a build dependency on libcurl, but like, who doesn't have libcurl?
