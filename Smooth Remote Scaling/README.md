# Smooth Remote Scaling
VRC only syncs your scale once every few seconds. This VRCFury prefab forcefully syncs and applies your local scale so that everyone else sees it change smoothly and immediately.

- 16 synced bits
- 3 constraints
- 1 animator layer

## FAQ

#### Does it work with \<insert scaling system here>?
All this prefab does is scale constrain your hip bone based on the `ScaleFactor` parameter. Anything that only controls your height through [OSC](https://docs.vrchat.com/docs/osc-avatar-scaling) will work.

#### It's not working...
There are a few situations where this system will turn off on purpose:
- `ScaleFactor` is bigger than 256, which is too large to sync.
- You entered a [station](https://creators.vrchat.com/worlds/components/vrc_station) at any point and then became tiny (`ScaleFactor` < 1).
  - It'll start working again if you scale back up or reload the avatar.
  - You'd be the wrong scale entirely if it stayed on. Stations are extremely cursed. Thanks VRC.
