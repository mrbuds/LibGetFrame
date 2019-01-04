local MAJOR_VERSION = "LibGetFrame-1.0"
local MINOR_VERSION = 1
if not LibStub then error(MAJOR_VERSION .. " requires LibStub.") end
local lib, oldversion = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

local maxDepth = 100

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
    ["SUFUnitplayer"] = true,
    ["PitBull4_Frames_Player"] = true,
    ["ElvUF_Player"] = true,
    ["oUF_TukuiPlayer"] = true,
    ["PlayerFrame"] = true,
}
local defaultTargetFrames = {
    ["SUFUnittarget"] = true,
    ["PitBull4_Frames_Target"] = true,
    ["ElvUF_Target"] = true,
    ["TargetFrame"] = true,
    ["oUF_TukuiTarget"] = true,
}
local defaultTargettargetFrames = {
    ["SUFUnittargetarget"] = true,
    ["PitBull4_Frames_TargetTarget"] = true,
    ["ElvUF_TargetTarget"] = true,
    ["TargetTargetFrame"] = true,
    ["oUF_TukuiTargetTarget"] = true,
}

local GetFramesCache = {}

local GetFramesCacheListener = CreateFrame("Frame")
GetFramesCacheListener:RegisterEvent("PLAYER_REGEN_DISABLED")
GetFramesCacheListener:RegisterEvent("PLAYER_REGEN_ENABLED")
GetFramesCacheListener:RegisterEvent("GROUP_ROSTER_UPDATE")
GetFramesCacheListener:SetScript("OnEvent", function(self, event, ...)
    GetFramesCache = {}
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

local function GetFrames(target)
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
    
    local results = {}
    for frame, unit in pairs(GetFramesCache) do
        --print("from cache:", frame:GetName())
        if UnitIsUnit(unit, target) then
            if frame:GetAttribute("unit") == unit then
                tinsert(results, frame)
            else
                results = {}
                break
            end
        end
    end
    
    return #results > 0 and results or FindButtonsForUnit(UIParent, target, 0)
end

local function ElvuiWorkaround(frame)
    if IsAddOnLoaded("ElvUI") and frame and frame:GetName():find("^ElvUF_") and frame.Health then
        return frame.Health
    else
        return frame
    end
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
        for k, v in pairs(opt.playerFrames) do
            ignoredFrames[k] = v
        end
    end
    if opt.ignoreTargetFrame then
        for k, v in pairs(opt.targetFrames) do
            ignoredFrames[k] = v
        end
    end
    if opt.ignoreTargettargetFrame then
        for k, v in pairs(opt.targettargetFrames) do
            ignoredFrames[k] = v
        end
    end

    local frames = GetFrames(target)
    if not frames then return nil end

    if not opt.returnAll then
        for i = 1, #opt.framePriorities do
            for _, frame in pairs(frames) do
                local name = frame:GetName()
                if not ignoredFrames[name] and name:find(opt.framePriorities[i]) then
                    return ElvuiWorkaround(frame)
                end
            end
        end
        local firstFrame = frames[1]
        if firstFrame and not ignoredFrames[firstFrame:GetName()] then
            return ElvuiWorkaround(firstFrame)
        end
    else
        for index, frame in pairs(frames) do
            if ignoredFrames[frame:GetName()] then
                frames[index] = nil
            else
                frames[index] = ElvuiWorkaround(frame)
            end
        end
        return frames
    end
end
