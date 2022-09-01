# LibGetFrame

Return unit frame for a given unit

## Usage

```Lua
local LGF = LibStub("LibGetFrame-1.0")
local frame = LGF.GetUnitFrame(unit , options)

-- For turning on accurate pet frames tracking use
LGF.TrackPets(true)
-- But it can be ressource intensive if your UI have a high number of frames and/or a high number of UNIT_PET events happen in encounter
```

## Options

- framePriorities : array

- ignorePlayerFrame : boolean (default true)
- ignoreTargetFrame : boolean (default true)
- ignoreTargettargetFrame : boolean (default true)
- ignorePartyFrame : boolean (default false)
- ignorePartyTargetFrame : boolean (default true)
- ignoreRaidFrame : boolean (default false)

- playerFrames : array
- targetFrames : array
- targettargetFrames : array
- partyFrames : array
- partyTargetFrames : array
- raidFrames : array
- ignoreFrames : array
- returnAll : boolean (default false)

For arrays check LibGetFrame-1.0.lua code for defaults

## Examples

### Glow player frame

```Lua
local LGF = LibStub("LibGetFrame-1.0")
local LCG = LibStub("LibCustomGlow-1.0")
local frame = LGF.GetUnitFrame("player")

if frame then
  LCG.ButtonGlow_Start(frame)
  -- LCG.ButtonGlow_Stop(frame)
end
```

### Glow every frames for your target

```Lua
local LGF = LibStub("LibGetFrame-1.0")
local LCG = LibStub("LibCustomGlow-1.0")

local frames = LGF.GetUnitFrame("target", {
      ignorePlayerFrame = false,
      ignoreTargetFrame = false,
      ignoreTargettargetFrame = false,
      returnAll = true,
})

for _, frame in pairs(frames) do
   LCG.ButtonGlow_Start(frame)
   --LCG.ButtonGlow_Stop(frame)
end
```

### Ignore Vuhdo panel 2 and 3

```Lua
local frame = LGF.GetUnitFrame("player", {
      ignoreFrames = { "Vd2.*", "Vd3.*" }
})
```

[GitHub Project](https://github.com/mrbuds/LibGetFrame)
