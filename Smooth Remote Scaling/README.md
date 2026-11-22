# Smooth Remote Scaling
VRC only syncs your scale once every few seconds. This VRCFury prefab forcefully syncs and applies your local scale so that everyone else sees it change smoothly and immediately.

- 17 synced bits
- 3 constraints
- 1 animator layer

## FAQ

#### Does it work with \<insert scaling system here>?
All this prefab does is scale constrain your hip bone based on the ScaleFactor parameter. Anything that only controls your height through [OSC](https://docs.vrchat.com/docs/osc-avatar-scaling) will work.

#### It's not working...
Smoothing turns off if ScaleFactor > 256 because it can't sync a number that big. If you're smaller than 256 times your avatar's default height, and it's still acting incorrect, please make a bug report.
