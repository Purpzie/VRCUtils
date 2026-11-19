# Face Tracking Templates
If your avatar uses [Jerry's Face Tracking Templates](https://github.com/Adjerry91/VRCFaceTracking-Templates), here are some prefabs to help you convert it to the [VRC-native system](https://vrc-beta-docs.netlify.app/avatars/face-tracking) without requiring any new blendshapes.

> [!NOTE]
> ARkit and corrective blendshapes aren't supported yet, but I plan to add those in the future.

## Setup
1. Remove Jerry's template from the avatar.
2. Depending on which template you just removed, drag one of the prefabs from this folder onto the avatar.

Their face will now act nearly the same as before, including all of Jerry's adjustments. It'll be around 300-400 FT operations which is well within excellent rank.

## FAQ/Issues
- Where did the toggles go?
   - VRC automatically detects FT now, so avatars don't need toggles for it anymore. You can still find FT settings in VRC's big settings menu under `Tracking and IK`.
   - While it's *technically* possible to add emulation and limits toggles, they would blow up your avatar's performance rank. Feel free to tweak the expressions to do whatever you want before uploading.
   - Eye dilation works by default, but the toggle was removed for similar reasons.
- Clicking the controller in the prefab lags the editor
   - Blame the VRC SDK. It doesn't like rendering that many FT settings in the inspector. Don't worry, your avatar will perform fine ingame.
- I'm getting a "Face Tracking mesh is already configured" error
   - VRCFury only lets one thing drive FT blendshapes on a mesh at a time. Remove your `Body` mesh from the descriptor's face tracking settings. If the avatar requires it, you can unpack the FT prefab and put your extra blendshapes there.
- Eyes bones rotate too much or not enough
   - The prefabs animate eye bones as if they were using default humanoid muscles. This works around [an issue](https://feedback.vrchat.com/avatar-30/p/separate-eye-look-angles-for-face-tracking) where VRC doesn't allow different eyelook settings for face tracking. Unfortunately, it's impossible for the prefab to check if the muscles were changed. You can either remove `Eye Rotation Fix` from the prefab and configure your eyelook settings for face tracking, or edit the animations.
- My ears/tail/etc don't do anything anymore
   - See the sections below.

## Extra animator stuff
If your avatar does anything extra with face tracking, like animating ears or wagging a tail, then some parameters need to be [forwarded to the animator](https://creators.vrchat.com/avatars/face-tracking/#parameter-behaviors). You can configure this in the avatar's face tracking section after enabling "Use All Tracking Keys". Only forward what the avatar needs.

Some of Jerry's parameters need custom expressions because of the lack of simplified/blended shapes. Those are listed below, and all others are one to one.

| Forwarded Parameter | Custom Expression |
| --- | --- |
| OSCm/Proxy/FT/v2/**EyeLidLeft** | `(1 - EyeClosedLeft) * 0.75 + EyeWideLeft * 0.25` |
| OSCm/Proxy/FT/v2/**EyeLidRight** | `(1 - EyeClosedRight) * 0.75 + EyeWideRight * 0.25` |
| OSCm/Proxy/FT/v2/**BrowExpressionLeft** | `(BrowInnerUpLeft + BrowOuterUpLeft) / 2 - (BrowLowererLeft * 0.75 + BrowPinchLeft * 0.25)` |
| OSCm/Proxy/FT/v2/**BrowExpressionRight** | `(BrowInnerUpRight + BrowOuterUpRight) / 2 - (BrowLowererRight * 0.75 + BrowPinchRight * 0.25)` |
| OSCm/Proxy/FT/v2/**CheekPuffSuckLeft** | `CheekPuffLeft - CheekSuckLeft` |
| OSCm/Proxy/FT/v2/**CheekPuffSuckRight** | `CheekPuffRight - CheekSuckRight` |
| OSCm/Proxy/FT/v2/**EyeLeftX** | `EyeLookInLeft - EyeLookOutLeft` |
| OSCm/Proxy/FT/v2/**EyeRightX** | `EyeLookOutRight - EyeLookInRight` |
| OSCm/Proxy/FT/v2/**EyeY** | `(EyeLookUpLeft + EyeLookUpRight - EyeLookDownLeft - EyeLookDownRight) / 2` |
| OSCm/Proxy/FT/v2/**JawX** | `JawRight - JawLeft` |
| OSCm/Proxy/FT/v2/**LipFunnel** | `(LipFunnelUpperLeft + LipFunnelUpperRight + LipFunnelLowerLeft + LipFunnelLowerRight) / 4` |
| OSCm/Proxy/FT/v2/**LipPucker** | `(LipPuckerUpperRight + LipPuckerUpperLeft + LipPuckerLowerRight + LipPuckerLowerLeft) / 4` |
| OSCm/Proxy/FT/v2/**LipSuckLower** | `(LipSuckLowerRight + LipSuckLowerLeft) / 2` |
| OSCm/Proxy/FT/v2/**LipSuckUpper** | `(LipSuckUpperRight + LipSuckUpperLeft) / 2` |
| OSCm/Proxy/FT/v2/**MouthLowerDown** | `(MouthLowerDownLeft + MouthLowerDownRight) / 2` |
| OSCm/Proxy/FT/v2/**MouthPress** | `(MouthPressLeft + MouthPressRight) / 2` |
| OSCm/Proxy/FT/v2/**MouthX** | `(MouthUpperRight + MouthLowerRight - MouthUpperLeft - MouthLowerLeft) / 2` |
| OSCm/Proxy/FT/v2/**NoseSneer** | `(NoseSneerLeft + NoseSneerRight) / 2` |
| OSCm/Proxy/FT/v2/**TongueX** | `TongueRight - TongueLeft` |
| OSCm/Proxy/FT/v2/**TongueY** | `TongueUp - TongueDown` |
| OSCm/Proxy/FT/v2/**SmileFrownLeft** | `MouthCornerPullLeft * 0.8 + MouthCornerSlantLeft * 0.2 - MouthFrownLeft` |
| OSCm/Proxy/FT/v2/**SmileFrownRight** | `MouthCornerPullRight * 0.8 + MouthCornerSlantRight * 0.2 - MouthFrownRight` |
| OSCm/Proxy/FT/v2/**SmileSadLeft** | `MouthCornerPullLeft * 0.8 + MouthCornerSlantLeft * 0.2 - max(MouthFrownLeft, MouthStretchLeft)` |
| OSCm/Proxy/FT/v2/**SmileSadRight** | `MouthCornerPullRight * 0.8 + MouthCornerSlantRight * 0.2 - max(MouthFrownRight, MouthStretchRight)` |

## Changed/removed parameters
- `EyeTrackingActive` is now provided by VRChat as `UserEyeTracking`[^1]
- `LipTrackingActive` is now provided by VRChat as `UserFaceTracking`[^1]
- `EyeDilationEnable` was removed, but eye dilation tracking still works by default.
- `VisemesEnable` was removed. At the time of writing this, VRCFury's `Disable Visemes` action disables mouth tracking entirely.

[^1]: The prefab copies the new parameters to the old ones, so you probably don't need to worry about this. Please use the new names if you're adding face tracking support to a new avatar.

---

Heavily based on, and uses resources from, [Adjerry91's Face Tracking Templates](https://github.com/Adjerry91/VRCFaceTracking-Templates):

```
MIT License

Copyright (c) 2023 Adjerry91

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
