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

-- 2. Load template (which inserts at beginning), then select Records+subtracks and move to end
local template_path = utils.JoinPath(reaper.GetResourcePath(), "TrackTemplates", "Record Band.RTrackTemplate")
local template_file = io.open(template_path, "r")
if not template_file then
	reaper.ShowMessageBox("Template file not found at:\n" .. template_path, "Error", 0)
	return
end
template_file:close()

reaper.Main_openProject("noprompt:" .. template_path, false)

-- Select Records track and all its subtracks
local records_track, records_idx, count_selected = utils.SelectRecordsAndSubtracks()
if not records_track then
	reaper.ShowMessageBox("Records track not found in template!", "Error", 0)
	return
end

-- Collect selected tracks' state chunks (in order) and their indices
local selected_tracks = {}
local track_states = {}
local track_indices = {}

for i = 0, reaper.CountTracks(0) - 1 do
	local track = reaper.GetTrack(0, i)
	if reaper.IsTrackSelected(track) then
		table.insert(selected_tracks, track)
		table.insert(track_indices, i)
		local _, state = reaper.GetTrackStateChunk(track, "", false)
		table.insert(track_states, state)
	end
end

-- Delete selected tracks from their current positions (delete in reverse order to preserve indices)
for i = #selected_tracks, 1, -1 do
	reaper.DeleteTrack(selected_tracks[i])
end

-- Re-add them at the end (preserves parent-child relationships since we maintain order)
for _, state in ipairs(track_states) do
	local idx = reaper.CountTracks(0)
	reaper.InsertTrackAtIndex(idx, false)
	local track = reaper.GetTrack(0, idx)
	reaper.SetTrackStateChunk(track, state, false)
end

reaper.UpdateArrange()
