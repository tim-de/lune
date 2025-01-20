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
- This currently isn't very accurate. It gets the phase based on a recent
known new moon, which has turned out to be a worse approximation than
previously thought, so I plan to replace this with a more accurate direct
calculation which will also remove the need to get data from the internet
