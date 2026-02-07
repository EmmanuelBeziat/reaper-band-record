-- DeleteRecordsTracks.lua - Remove the Records track and all its subtracks
-- Workflow:
-- 1) Find track named 'Records' and its subtracks
-- 2) If subtracks have content, warn that it will be lost if not rendered and ask confirmation
-- 3) Delete Records track and all subtracks (from bottom up to preserve indices)

local reaper = reaper

-- Import shared utilities (path relative to this script)
local script_path = (debug.getinfo(1, "S").source):gsub("^@", ""):gsub("\\", "/")
local script_dir = script_path:match("^(.+)/[^/]*$") or "."
local utils = dofile(script_dir .. "/utils/Utils.lua")

local MSG_RECORDS_NOT_FOUND = "Track 'Records' not found!"
local MSG_SUBTRACKS_HAVE_CONTENT = "Records subtracks contain items.\nThey will be lost if not rendered.\n\nDelete anyway?"

-- 1. Find Records track (don't change selection yet so we can get index for AreSubtracksEmpty)
local records_track, records_idx = utils.FindTrack("Records")

if not records_track then
	reaper.ShowMessageBox(MSG_RECORDS_NOT_FOUND, "Error", 0)
	return
end

-- 2. Check if subtracks have content; if so, warn and ask confirmation
if not utils.AreSubtracksEmpty(records_track, records_idx) then
	local choice = reaper.ShowMessageBox(MSG_SUBTRACKS_HAVE_CONTENT, "Delete Records tracks", 1)
	if choice ~= 1 then
		return
	end
end

reaper.Undo_BeginBlock()

-- Select Records and all subtracks, then collect them and delete from last to first
utils.SelectRecordsAndSubtracks()

local tracks_to_delete = {}
for i = 0, reaper.CountTracks(0) - 1 do
	local track = reaper.GetTrack(0, i)
	if reaper.IsTrackSelected(track) then
		table.insert(tracks_to_delete, track)
	end
end

-- Delete from last to first so indices remain valid
for i = #tracks_to_delete, 1, -1 do
	reaper.DeleteTrack(tracks_to_delete[i])
end

reaper.UpdateArrange()
reaper.Undo_EndBlock("Band Record: Delete Records tracks", -1)
