-- RecordTracks.lua - Prepare and start recording on Records group
-- Workflow:
-- 1) Mute Records track
-- 2) Mute Track track
-- 3) Arm all subtracks of Records for recording
-- 4) Move cursor to project start
-- 5) Start recording

local reaper = reaper

-- Import shared utilities
local utils = dofile(reaper.GetResourcePath() .. "/Scripts/Record Band/EB Record Band/utils/EB_Utils.lua")

-- 1. Mute Records track
local records_track, records_idx = utils.FindTrack("Records")
if records_track then
	reaper.SetMediaTrackInfo_Value(records_track, "B_MUTE", 1)
else
	reaper.ShowMessageBox("Track 'Records' not found!", "Error", 0)
	return
end

-- 2. Mute Track track
local track_track = utils.FindTrack("Track")
if track_track then
	reaper.SetMediaTrackInfo_Value(track_track, "B_MUTE", 1)
end

-- 2.5. Check if subtracks of Records are empty
local records_depth = reaper.GetTrackDepth(records_track)
local has_content = false
for i = records_idx + 1, reaper.CountTracks(0) - 1 do
	local subtrack = reaper.GetTrack(0, i)
	local subtrack_depth = reaper.GetTrackDepth(subtrack)

	-- Stop when we reach a track that's not a subtrack
	if subtrack_depth <= records_depth then
		break
	end

	-- Check if subtrack has any items
	if reaper.CountTrackMediaItems(subtrack) > 0 then
		has_content = true
		break
	end
end

if has_content then
	reaper.ShowMessageBox("Warning: Records subtracks are not empty!\nPlease clear them before recording.", "Error", 0)
	return
end

-- 3. Arm all subtracks of Records for recording
utils.SetSubtracksRecordArm(records_track, records_idx, 1)

-- 4. Move cursor to project start
reaper.SetEditCurPos(0, false, false)

-- 5. Start recording
reaper.Main_OnCommand(1013, 0)  -- Transport: Record
