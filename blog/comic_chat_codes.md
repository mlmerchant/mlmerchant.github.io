# Technical Breakdown of Microsoft Comic Chat Avatar Gesture and Expression Codes

Microsoft Comic Chat encodes avatar gestures and expressions within IRC messages using a parenthetical format. The following is a detailed technical explanation intended to assist developers and hackers interested in understanding or reverse-engineering this format:

## Format Overview

The gesture and expression metadata is encapsulated in parentheses in the format:

```
(#GabcEdefRMgTname1,name2,...,nameN)
```

The capital letters (G, E, R, M, T) represent literal character constants. Lowercase letters (`a`, `b`, `c`, `d`, `e`, `f`, etc.) represent byte values encoded as ASCII characters offset from '0' (decimal 48).

## Gesture ('G') Details

- `a` (first byte after `G`): Represents the **index** of the body pose from the avatar file, starting from ASCII '0' (decimal 48). Thus:
  - `'0'` = First body pose
  - `'='` = 14th body pose (ASCII value decimal 61)

- `b` (second byte): Represents the **emotion** associated with the body gesture. Emotions are encoded as follows:

```
'0' (48) = NULL
'1' (49) = HAPPY
'2' (50) = COY
'3' (51) = BORED
'4' (52) = SCARED
'5' (53) = SAD
'6' (54) = ANGRY
'7' (55) = SHOUT
'8' (56) = LAUGH
'9' (57) = NEUTRAL
':' (58) = WAVE
';' (59) = POINTOTHER
'<' (60) = POINTSELF
'=' (61) = DOUBLEPOINT
'>' (62) = SHRUG
'?' (63) = 3QRWALK
'@' (64) = SIDEWALK
'A' (65) = 3QFWALK
```

- `c` (third byte): Represents the **intensity** of the emotion from `'0'` (minimum) to `':'` (maximum).

## Expression ('E') Details

Expression (`E`) bytes mirror gesture (`G`) bytes in structure but refer specifically to the head or facial expression:

- `d` (first byte after `E`): Index of the facial expression from the avatar file, starting from `'0'`.
- `e` (second byte): Emotion (identical encoding as gesture emotions above).
- `f` (third byte): Intensity, ranging from `'0'` (least intense) to `':'` (most intense).

## Additional Flags

- **Requested ('R')**: Indicates the pose or expression was explicitly requested by a user interaction (e.g., emotion wheel).

- **Mode ('M')**: Represents the type of speech balloon:

```
'0' (48) = NULL
'1' (49) = SAY (regular balloon)
'2' (50) = WHISPER (dashed balloon)
'3' (51) = THINK (thought bubble with circles)
'4' (52) = SHOUT (likely capitalized text)
'5' (53) = ACTION (narration box)
```

- **Targets ('T')**: If present, followed by comma-separated IRC handles, indicating message recipients.

## Example

```
(#G1:H2E0;A3RM1Tuser123,user456)
```

This hypothetical example would represent:
- Gesture: HAPPY (`1`) at high intensity (`:`), second body pose (`H`).
- Expression: POINTOTHER (`;`) with intensity medium-high (`A`), first head pose (`0`).
- Requested (`R`) via user action.
- Mode: WHISPER (`1`).
- Targets: `user123`, `user456`.

---

This documentation is intended as a foundational reference for those exploring or developing tools related to Microsoft Comic Chat. Verification and experimentation within the original application are recommended to confirm these interpretations.

