local MAJOR_VERSION = "LibGetFrame-1.0"
local MINOR_VERSION = 4
if not LibStub then error(MAJOR_VERSION .. " requires LibStub.") end
local lib, oldversion = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

local InCombatLockdown, UnitIsUnit, tinsert = InCombatLockdown, UnitIsUnit, tinsert

local maxDepth = 50

local defaultFramePriorities = {
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

local defaultPlayerFrames = {
    "SUFUnitplayer",
    "PitBull4_Frames_Player",
    "ElvUF_Player",
    "oUF_TukuiPlayer",
    "PlayerFrame",
}
local defaultTargetFrames = {
    "SUFUnittarget",
    "PitBull4_Frames_Target",
    "ElvUF_Target",
    "TargetFrame",
    "oUF_TukuiTarget",
}
local defaultTargettargetFrames = {
    "SUFUnittargetarget",
    "PitBull4_Frames_TargetTarget",
    "ElvUF_TargetTarget",
    "TargetTargetFrame",
    "oUF_TukuiTargetTarget",
}

local GetFramesCache = {}
local GetFramesCacheLockdown = {}

local GetFramesCacheListener = CreateFrame("Frame")
GetFramesCacheListener:RegisterEvent("PLAYER_REGEN_DISABLED")
GetFramesCacheListener:RegisterEvent("PLAYER_REGEN_ENABLED")
GetFramesCacheListener:RegisterEvent("GROUP_ROSTER_UPDATE")
GetFramesCacheListener:SetScript("OnEvent", function(self, event, ...)
    GetFramesCache = {}
    GetFramesCacheLockdown = {}
end)

local function FindButtonsForUnit(frame, target, depth)
    local results = {}
    if depth < maxDepth and type(frame) == "table" and not frame:IsForbidden() then
        local type = frame:GetObjectType()
        if type == "Frame" or type == "Button" then
            for _, child in ipairs({frame:GetChildren()}) do
                for _, v in pairs(FindButtonsForUnit(child, target, depth + 1)) do
                    tinsert(results, v)
                end
            end
        end
        if type == "Button" then
            local unit = frame:GetAttribute("unit")
            if unit and frame:IsVisible() and frame:GetName() then
                GetFramesCache[frame] = unit
                if UnitIsUnit(unit, target) then
                    tinsert(results, frame)
                end
            end
        end
    end
    return results
end

local function GetFrames(target, ignoredFrames)
    if GetFramesCacheLockdown[target] then
        return {}
    end
    if not UnitExists(target) then
        if type(target) == "string" and target:find("Player") then
            target = select(6,GetPlayerInfoByGUID(target))
        else
            target = target:gsub(" .*", "")
            if not UnitExists(target) then
                return {}
            end
        end
    end 
    
    local frames = {}
    for frame, unit in pairs(GetFramesCache) do
        --print("from cache:", frame:GetName())
        if UnitIsUnit(unit, target) then
            if frame:GetAttribute("unit") == unit then
                tinsert(frames, frame)
            else
                frames = {}
                break
            end
        end
    end

    frames = #frames > 0 and frames or FindButtonsForUnit(UIParent, target, 0)

    -- if we are in combat and no frame was found we want to blacklist unit until cache is wiped
    if #frames == 0 and InCombatLockdown() then
        GetFramesCacheLockdown[target] = true
    end

    -- filter ignored frames
    for k, frame in pairs(frames) do
        local name = frame:GetName()
        for j, filter in pairs(ignoredFrames) do
            if name:find(filter) then
                frames[k] = nil
            end
        end
    end
    
    return frames
end

local function ElvuiWorkaround(frame)
    if IsAddOnLoaded("ElvUI") and frame and frame:GetName():find("^ElvUF_") and frame.Health then
        return frame.Health
    else
        return frame
    end
end

local function TableConcat(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

function lib.GetFrame(target, opt)
    opt = opt or {}
    setmetatable(opt, {
        __index = {
            framePriorities = defaultFramePriorities,
            ignorePlayerFrame = true,
            ignoreTargetFrame = true,
            ignoreTargettargetFrame = true,
            playerFrames = defaultPlayerFrames,
            targetFrames = defaultTargetFrames,
            targettargetFrames = defaultTargettargetFrames,
            ignoreFrames = {},
            returnAll = false,
        }
    })

    if not target then return end

    local ignoredFrames = opt.ignoreFrames
    if opt.ignorePlayerFrame then
        ignoredFrames = TableConcat(ignoredFrames, opt.playerFrames)
    end
    if opt.ignoreTargetFrame then
        ignoredFrames = TableConcat(ignoredFrames, opt.targetFrames)
    end
    if opt.ignoreTargettargetFrame then
        ignoredFrames = TableConcat(ignoredFrames, opt.targettargetFrames)
    end
  
    local frames = GetFrames(target, ignoredFrames)
    if not frames then return nil end

    if not opt.returnAll then
        for i = 1, #opt.framePriorities do
            for _, frame in pairs(frames) do
                local name = frame:GetName()
                if name:find(opt.framePriorities[i]) then
                    return ElvuiWorkaround(frame)
                end
            end
        end
        if frames[1] then
            return ElvuiWorkaround(frames[1])
        end
    else
        for index, frame in pairs(frames) do
            frames[index] = ElvuiWorkaround(frame)
        end
        return frames
    end
end
