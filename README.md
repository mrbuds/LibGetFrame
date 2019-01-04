# LibGetFrame

Return unit frame for a given unit

Usage :
```
local LGF = LibStub("LibGetFrame-1.0")
local frame = LGF.GetFrame(unit , options)
```

options :

  - framePriorities : array, default :
```
{
    -- raid frames
    [1] = "^Vd1", -- vuhdo
    [2] = "^Vd2", -- vuhdo
    [3] = "^Vd3", -- vuhdo
    [4] = "^Vd4", -- vuhdo
    [5] = "^Vd5", -- vuhdo
    [6] = "^Vd", -- vuhdo
    [7] = "^HealBot", -- healbot
    [8] = "^GridLayout", -- grid
    [9] = "^Grid2Layout", -- grid2
    [10] = "^ElvUF_RaidGroup", -- elv
    [11] = "^oUF_bdGrid", -- bdgrid
    [12] = "^oUF.*raid", -- generic oUF
    [13] = "^LimeGroup", -- lime
    [14] = "^SUFHeaderraid", -- suf
    [15] = "^CompactRaid", -- blizz
    -- party frames
    [16] = "^SUFHeaderparty", --suf
    [17] = "^ElvUF_PartyGroup", -- elv
    [18] = "^oUF.*party", -- generic oUF
    [19] = "^PitBull4_Groups_Party", -- pitbull4
    [20] = "^CompactParty", -- blizz
    -- player frame
    [21] = "^SUFUnitplayer",
    [22] = "^PitBull4_Frames_Player",
    [23] = "^ElvUF_Player",
    [24] = "^oUF.*player",
    [25] = "^PlayerFrame",
}
```
  - ignorePlayerFrame : boolean (default true)
  - ignoreTargetFrame : boolean (default true)
  - ignoreTargettargetFrame : boolean (default true)
  - playerFrames : array, default :
```
{
    "SUFUnitplayer",
    "PitBull4_Frames_Player",
    "ElvUF_Player",
    "oUF_TukuiPlayer",
    "PlayerFrame",
}
```
  - targetFrames : array, default :
```
{
    "SUFUnittarget",
    "PitBull4_Frames_Target",
    "ElvUF_Target",
    "TargetFrame",
    "oUF_TukuiTarget",
}
```
  - targettargetFrames : array, default :
```
{
    "SUFUnittargetarget",
    "PitBull4_Frames_TargetTarget",
    "ElvUF_TargetTarget",
    "TargetTargetFrame",
    "oUF_TukuiTargetTarget",
}
```
  - ignoreFrames : array, default :
```
{ }
```
  - returnAll : boolean (default false)

Example :

Glow player frame
```
local LGF = LibStub("LibGetFrame-1.0")
local LCG = LibStub("LibCustomGlow-1.0")
local frame = LGF.GetFrame("player")

if frame then
  LCG.ButtonGlow_Start(frame)
  -- LCG.ButtonGlow_Stop(frame)
end
```

Glow every frames for your target
```
local LGF = LibStub("LibGetFrame-1.0")
local LCG = LibStub("LibCustomGlow-1.0")

local frames = LGF.GetFrame("target", {
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

Ignore Vuhdo panel 2 and 3
```
local frame = LGF.GetFrame("player", {
      ignoreFrames = { "Vd2.*", "Vd3.*" }
})
```
