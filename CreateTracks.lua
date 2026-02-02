-- CreateTracks.lua - Create Records track group from template
-- Workflow:
-- 1) Check if Records track already exists
-- 2) Add a separator track at the end
-- 3) Load Record Band template from TrackTemplates/Live
-- 4) Insert tracks from template after the separator

local reaper = reaper

-- Import shared utilities
local utils = dofile(reaper.GetResourcePath() .. "/Scripts/EmmanuelBeziat/Band Record/utils/Utils.lua")

-- 1. Check if Records track already exists
local records_track = utils.FindTrack("Records")
if records_track then
	reaper.ShowMessageBox("Track 'Records' already exists. No action taken.", "Info", 0)
	return
end

-- 2. Add spacer at the end
local num_tracks = reaper.CountTracks(0)
reaper.InsertTrackAtIndex(num_tracks, false)
local spacer_track = reaper.GetTrack(0, num_tracks)
reaper.SetMediaTrackInfo_Value(spacer_track, "I_SPACER", 1)

-- 3. Load template and insert tracks
local template_path = utils.JoinPath(reaper.GetResourcePath(), "TrackTemplates", "Record Band.RTrackTemplate")
local template_file = io.open(template_path, "r")

if not template_file then
	reaper.ShowMessageBox("Template file not found at:\n" .. template_path, "Error", 0)
	return
end

-- Read template file
local template_content = template_file:read("*a")
template_file:close()

-- Extract track chunks from template
-- RTrackTemplate files have <TRACK...> blocks that end with > on a line
-- Use a pattern that matches from <TRACK to the closing >
local track_chunks = {}

-- Replace newlines temporarily to handle multiline matching in Lua 5.1
-- Pattern: <TRACK...> (where ... includes newlines and attributes, ends with >)
local temp_content = template_content:gsub("\r\n", "\n")  -- Normalize newlines
for chunk in temp_content:gmatch("<TRACK[^<]*>") do
	-- Add closing tag to make chunk complete
	local complete_chunk = chunk .. "\n</TRACK>"
	table.insert(track_chunks, complete_chunk)
end

-- Debug: show what we found
if #track_chunks == 0 then
	reaper.ShowMessageBox("No tracks found in template and couldn't write debug file.", "Error", 0)
end

-- 4. Insert tracks from template
for _, chunk in ipairs(track_chunks) do
	-- Insert track at the end and immediately apply chunk to avoid empty track
	local insert_idx = reaper.CountTracks(0)
	reaper.InsertTrackAtIndex(insert_idx, true)
	local new_track = reaper.GetTrack(0, insert_idx)
	reaper.SetTrackStateChunk(new_track, chunk, false)
end

reaper.UpdateArrange()
