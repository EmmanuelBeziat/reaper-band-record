-- RenderTracks.lua - Render 'Records' group as MP3 320kbps stems
-- Workflow:
-- 1) Deselect all tracks, find track named 'Records' and select it + its children
-- 2) Unmute selected tracks
-- 3) Ensure output folder: <project root>/Records/<YYYY-MM-DD>
-- 4) Apply an existing render preset (created with cfillion_Apply render preset)
--    which contains the correct source (Selected tracks (stems)), pattern ($track)
--    and format (LAME MP3 320). If the preset action is missing, fallback to
--    setting the required RENDER_* values directly.
-- 5) Launch automatic render using the most recent render settings.

local reaper = reaper

-- Import shared utilities
local utils = dofile(reaper.GetResourcePath() .. "/Scripts/EmmanuelBeziat/Band Record/utils/Utils.lua")

-- 1-3. Deselect all, find Records track, select it + subtracks, unmute
local records_track, records_idx = utils.SelectRecordsAndSubtracks()

if not records_track then
	reaper.ShowMessageBox("Track 'Records' not found!", "Error", 0)
	return
end

-- Unmute all selected tracks
utils.SetSelectedTracksMute(0)

-- 4. Get render path and create folder structure
local audio_folder = reaper.GetProjectPath("")
local project_root = utils.ParentPath(audio_folder) or audio_folder
local date_str = os.date("%Y-%m-%d %Hh%Mm")
local render_folder = utils.JoinPath(project_root, "Records", date_str)

utils.CreateDirectory(render_folder)
-- Apply render preset via cfillion script dynamically (no hardcoded action ID)
-- Set this to the name of the preset you saved in REAPER's render dialog
local preset_to_apply = "StemsExport"
local cfillion_script = utils.JoinPath(reaper.GetResourcePath(), "Scripts", "ReaTeam Scripts", "Rendering", "cfillion_Apply render preset.lua")
local f = io.open(cfillion_script, "r")
if f then
	f:close()
	-- The cfillion script looks for a global `ApplyPresetByName` variable
	-- when present it applies the preset silently. Set it and run the script.
	ApplyPresetByName = preset_to_apply
	dofile(cfillion_script)
	ApplyPresetByName = nil
else
	reaper.ShowMessageBox(
		"Optional script not found:\n\n" ..
		"cfillion_Apply render preset.lua\n\n" ..
		"Install it via ReaPack: ReaTeam Scripts → Rendering → \"cfillion_Apply render preset\".\n\n" ..
		"Rendering will use built-in settings (stems, $track, MP3 320) instead of your \"StemsExport\" preset.",
		"cfillion script missing",
		0
	)
	-- Fallback: set required render flags directly (stems via master + pattern + MP3)
	reaper.GetSetProjectInfo(0, "RENDER_SETTINGS", 130, true)
	reaper.GetSetProjectInfo_String(0, "RENDER_PATTERN", "$track", true)
	reaper.GetSetProjectInfo_String(0, "RENDER_FORMAT", "l3pm", true)
end

-- Ensure output directory is our render folder (override preset if needed)
reaper.GetSetProjectInfo_String(0, "RENDER_FILE", render_folder, true)

-- Trigger automatic render using the most recent render settings
reaper.Main_OnCommand(41824, 0)
reaper.SetMediaTrackInfo_Value(records_track, "B_MUTE", 1)

-- Mute the Records track after rendering (always, regardless of initial state)
reaper.SetMediaTrackInfo_Value(records_track, "B_MUTE", 1)

reaper.ShowMessageBox("Render completed. Files saved to:\n" .. render_folder, "Render Complete", 0)
