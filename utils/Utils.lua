-- EB_Utils.lua - Shared utilities for EB Record Band scripts
-- Contains common functions for track selection and manipulation
-- Path helpers use forward slashes (/) for cross-platform (Windows + macOS).

local reaper = reaper

-- Normalize path: use forward slashes so paths work on Windows and macOS
function EB_NormalizePath(path)
	if not path or path == "" then return path end
	return (path:gsub("\\", "/"))
end

-- Get parent directory of a path (handles both / and \)
function EB_ParentPath(path)
	if not path or path == "" then return path end
	local normalized = EB_NormalizePath(path)
	return normalized:match("^(.+)/[^/]*$") or path
end

-- Join path segments with forward slashes (no double slashes)
function EB_JoinPath(...)
	local parts = { ... }
	for i, p in ipairs(parts) do
		parts[i] = EB_NormalizePath(tostring(p)):gsub("^/+", ""):gsub("/+$", "")
	end
	return table.concat(parts, "/")
end

-- Create directory (cross-platform: Windows, macOS, Linux)
function EB_CreateDirectory(path)
	local normalized = EB_NormalizePath(path)
	local os_name = reaper.GetOS()
	if os_name == "Win32" or os_name == "Win64" then
		os.execute('mkdir "' .. normalized .. '" 2>nul')
	else
		os.execute('mkdir -p "' .. normalized .. '"')
	end
end

-- Deselect all tracks
function EB_DeselectAllTracks()
	for i = 0, reaper.CountTracks(0) - 1 do
		local track = reaper.GetTrack(0, i)
		reaper.SetTrackSelected(track, false)
	end
end

-- Find track by name
-- Returns: track object, track index, or nil if not found
function EB_FindTrack(track_name)
	for i = 0, reaper.CountTracks(0) - 1 do
		local track = reaper.GetTrack(0, i)
		local _, name = reaper.GetTrackName(track)
		if name == track_name then
			return track, i
		end
	end
	return nil, nil
end

-- Select a track and all its subtracks by depth
-- track: track object to select (parent)
-- track_idx: index of the parent track
-- Returns: number of selected tracks (including parent)
function EB_SelectTrackAndSubtracks(track, track_idx)
	local count = 1
	reaper.SetTrackSelected(track, true)

	local track_depth = reaper.GetTrackDepth(track)
	for i = track_idx + 1, reaper.CountTracks(0) - 1 do
		local subtrack = reaper.GetTrack(0, i)
		local subtrack_depth = reaper.GetTrackDepth(subtrack)

		-- Stop when we reach a track that's not a subtrack
		if subtrack_depth <= track_depth then
			break
		end

		reaper.SetTrackSelected(subtrack, true)
		count = count + 1
	end

	return count
end

-- Find Records track, deselect all, then select Records + subtracks
-- Returns: records_track, records_idx, count_selected (or nil, nil, 0 if not found)
function EB_SelectRecordsAndSubtracks()
	EB_DeselectAllTracks()

	local records_track, records_idx = EB_FindTrack("Records")
	if not records_track then
		return nil, nil, 0
	end

	local count = EB_SelectTrackAndSubtracks(records_track, records_idx)
	return records_track, records_idx, count
end

-- Apply mute/unmute to all selected tracks
-- state: 0 = unmute, 1 = mute
function EB_SetSelectedTracksMute(state)
	for i = 0, reaper.CountTracks(0) - 1 do
		local track = reaper.GetTrack(0, i)
		if reaper.IsTrackSelected(track) then
			reaper.SetMediaTrackInfo_Value(track, "B_MUTE", state)
		end
	end
end

-- Arm or disarm all subtracks of a parent track for recording
-- parent_track: parent track object
-- parent_idx: index of the parent track
-- state: 0 = disarm, 1 = arm
function EB_SetSubtracksRecordArm(parent_track, parent_idx, state)
	local parent_depth = reaper.GetTrackDepth(parent_track)
	for i = parent_idx + 1, reaper.CountTracks(0) - 1 do
		local subtrack = reaper.GetTrack(0, i)
		local subtrack_depth = reaper.GetTrackDepth(subtrack)

		-- Stop when we reach a track that's not a subtrack
		if subtrack_depth <= parent_depth then
			break
		end

		reaper.SetMediaTrackInfo_Value(subtrack, "I_RECARM", state)
	end
end

return {
	DeselectAllTracks = EB_DeselectAllTracks,
	FindTrack = EB_FindTrack,
	SelectTrackAndSubtracks = EB_SelectTrackAndSubtracks,
	SelectRecordsAndSubtracks = EB_SelectRecordsAndSubtracks,
	SetSelectedTracksMute = EB_SetSelectedTracksMute,
	SetSubtracksRecordArm = EB_SetSubtracksRecordArm,
	NormalizePath = EB_NormalizePath,
	ParentPath = EB_ParentPath,
	JoinPath = EB_JoinPath,
	CreateDirectory = EB_CreateDirectory,
}
