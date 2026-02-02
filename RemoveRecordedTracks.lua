-- RemoveRecordedTracks.lua - Clear all content from 'Records' group and its subtracks
-- Workflow:
-- 1) Deselect all tracks
-- 2) Find track named 'Records' and select it + its children
-- 3) Delete all content (items) from selected tracks
-- 4) Deselect all tracks

local reaper = reaper

-- Import shared utilities
local utils = dofile(reaper.GetResourcePath() .. "/Scripts/Band Record/Band Record/utils/Utils.lua")

-- 1-2. Deselect all, find Records track, select it + subtracks
local records_track, records_idx = utils.SelectRecordsAndSubtracks()

if not records_track then
	reaper.ShowMessageBox("Track 'Records' not found!", "Error", 0)
	return
end

-- 3. Delete all items from selected tracks
-- First, collect all items in selected tracks, then delete them
local items_to_delete = {}
for i = 0, reaper.CountTracks(0) - 1 do
	local track = reaper.GetTrack(0, i)
	if reaper.IsTrackSelected(track) then
		local item_count = reaper.CountTrackMediaItems(track)
		for j = 0, item_count - 1 do
			local item = reaper.GetTrackMediaItem(track, j)
			table.insert(items_to_delete, item)
		end
	end
end

-- Delete collected items
for _, item in ipairs(items_to_delete) do
	reaper.DeleteTrackMediaItem(reaper.GetMediaItemTrack(item), item)
end

-- Refresh the arrange view to immediately show the changes
reaper.UpdateArrange()

-- 4. Deselect all tracks
utils.DeselectAllTracks()

