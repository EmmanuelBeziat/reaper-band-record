-- RecordTracks.lua - Prepare and start recording on Records group
-- Workflow:
-- 1) Mute Records track
-- 2) Mute Track track
-- 3) Arm all subtracks of Records for recording
-- 4) Move cursor to project start
-- 5) Start recording

local reaper = reaper

-- Import shared utilities (path relative to this script)
local script_path = (debug.getinfo(1, "S").source):gsub("^@", ""):gsub("\\", "/")
local script_dir = script_path:match("^(.+)/[^/]*$") or "."
local utils = dofile(script_dir .. "/utils/Utils.lua")

-- 1. Mute Records track
local records_track, records_idx = utils.FindTrack("Records")
if not records_track then
	reaper.ShowMessageBox("Track 'Records' not found!", "Error", 0)
	return
end

reaper.Undo_BeginBlock()

reaper.SetMediaTrackInfo_Value(records_track, "B_MUTE", 1)

-- 2. Mute Track track
local track_track = utils.FindTrack("Track")
if track_track then
	reaper.SetMediaTrackInfo_Value(track_track, "B_MUTE", 1)
end

-- 2.5. Check if subtracks of Records are empty
if not utils.AreSubtracksEmpty(records_track, records_idx) then
	reaper.Undo_EndBlock("Band Record: Prepare recording", -1)
	reaper.ShowMessageBox("Warning: Records subtracks are not empty!\nPlease clear them before recording.", "Error", 0)
	return
end

-- 3. Arm all subtracks of Records for recording
utils.SetSubtracksRecordArm(records_track, records_idx, 1)

-- 4. Move cursor to project start
reaper.SetEditCurPos(0, false, false)

-- 5. Start recording
reaper.Undo_EndBlock("Band Record: Prepare recording", -1)
reaper.Main_OnCommand(1013, 0)  -- Transport: Record
