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
    [2] = "^Healbot", -- healbot
    [3] = "^GridLayout", -- grid
    [4] = "^Grid2Layout", -- grid2
    [5] = "^ElvUF_RaidGroup", -- elv
    [6] = "^oUF_bdGrid", -- bdgrid
    [7] = "^oUF.*raid", -- generic oUF
    [8] = "^LimeGroup", -- lime
    [9] = "^SUFHeaderraid", -- suf
    [10] = "^CompactRaid", -- blizz
    -- party frames
    [11] = "^SUFHeaderparty", --suf
    [12] = "^ElvUF_PartyGroup", -- elv
    [13] = "^oUF.*party", -- generic oUF
    [14] = "^PitBull4_Groups_Party", -- pitbull4
    [15] = "^CompactParty", -- blizz
    -- player frame
    [16] = "^SUFUnitplayer",
    [17] = "^PitBull4_Frames_Player",
    [18] = "^ElvUF_Player",
    [19] = "^oUF.*player",
    [20] = "^PlayerFrame",
}
```
  - ignorePlayerFrame : boolean (default true)
  - ignoreTargetFrame : boolean (default true)
  - ignoreTargettargetFrame : boolean (default true)
  - playerFrames : array, default :
```
{
    ["SUFUnitplayer"] = true,
    ["PitBull4_Frames_Player"] = true,
    ["ElvUF_Player"] = true,
    ["oUF_TukuiPlayer"] = true,
    ["PlayerFrame"] = true,
}
```
  - targetFrames : array, default :
```
{
    ["SUFUnittarget"] = true,
    ["PitBull4_Frames_Target"] = true,
    ["ElvUF_Target"] = true,
    ["TargetFrame"] = true,
    ["oUF_TukuiTarget"] = true,
}
```
  - targettargetFrames : array, default :
```
{
    ["SUFUnittargetarget"] = true,
    ["PitBull4_Frames_TargetTarget"] = true,
    ["ElvUF_TargetTarget"] = true,
    ["TargetTargetFrame"] = true,
    ["oUF_TukuiTargetTarget"] = true,
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
