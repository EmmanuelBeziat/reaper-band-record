-- CreateTracks.lua - Create Records track group from template
-- Workflow:
-- 1) Check if Records track already exists
-- 2) Load Record Band template and insert at the end of all tracks

local reaper = reaper

-- Import shared utilities
local utils = dofile(reaper.GetResourcePath() .. "/Scripts/Band Record/Band Record/utils/Utils.lua")

-- 1. Check if Records track already exists
local records_track = utils.FindTrack("Records")
if records_track then
	reaper.ShowMessageBox("Track 'Records' already exists. No action taken.", "Info", 0)
	return
end

-- 2. Insert a temporary track at the end, select it, then load template so REAPER inserts after it
local template_path = utils.JoinPath(reaper.GetResourcePath(), "TrackTemplates", "Record Band.RTrackTemplate")
local template_file = io.open(template_path, "r")
if not template_file then
	reaper.ShowMessageBox("Template file not found at:\n" .. template_path, "Error", 0)
	return
end
template_file:close()

local count_before = reaper.CountTracks(0)
reaper.InsertTrackAtIndex(count_before, false)
local anchor_track = reaper.GetTrack(0, count_before)
reaper.GetSetMediaTrackInfo_String(anchor_track, "P_NAME", "%%BAND_RECORD_ANCHOR%%", true)

utils.DeselectAllTracks()
reaper.SetTrackSelected(anchor_track, true)
reaper.Main_openProject("noprompt:" .. template_path, false)

local anchor_to_remove = utils.FindTrack("%%BAND_RECORD_ANCHOR%%")
if anchor_to_remove then
	reaper.DeleteTrack(anchor_to_remove)
end

reaper.UpdateArrange()
