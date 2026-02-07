# Band Record

Set of ReaScripts for recording a band in REAPER.

## Process

The workflow follows four main steps:

### 1. Create the Records group — **CreateTracks**

- Checks if a track named **Records** already exists (if so, does nothing).
- Loads the track template **Record Band** from `TrackTemplates/Record Band.RTrackTemplate` and inserts the tracks at the end of the track list.

**Requirement:** Save your band template as `Record Band.RTrackTemplate` in REAPER’s `TrackTemplates` folder (inside the Resource path).

---

### 2. Record — **RecordTracks**

- Mutes the **Records** track and the **Track** track (so you don’t hear them while recording).
- Checks that all subtracks under **Records** are empty; if not, shows an error and stops.
- Arms all subtracks of **Records** for recording.
- Moves the edit cursor to the start of the project and starts recording.

Run this when you’re ready to record a take.

---

### 3. Clear and re-record (optional) — **RemoveRecordedTracks**

- Selects the **Records** track and all its children.
- Deletes all media items on those tracks (keeps the tracks and routing).

Use this when you want to wipe a take and record again without removing the Records group.

---

### 4. Render stems — **RenderTracks**

- Selects the **Records** track and all its children and unmutes them.
- Creates a folder `Records\<YYYY-MM-DD HHhMMm>` under the project root.
- Applies the render preset **StemsExport** (from cfillion’s “Apply render preset”) to render selected tracks as stems. If that script/preset is missing, it falls back to: selected tracks (stems), pattern `$track`, LAME MP3.
- Sets the render output to the new folder and runs the render.
- Mutes the **Records** track again when done.

**Optional:** Install [cfillion’s Apply render preset](https://github.com/ReaTeam/ReaScripts/blob/master/ReaScripts/cfillion/Apply%20render%20preset.lua) and create a preset named **StemsExport** (e.g. stems, `$track`, MP3 320) for consistent results.

---

## Summary

| Step | Script                 | Action                          |
|------|------------------------|---------------------------------|
| 1    | **CreateTracks**       | Add Records group from template |
| 2    | **RecordTracks**       | Arm, mute monitor, start record |
| 3    | **RemoveRecordedTracks** | Clear items on Records (optional) |
| 4    | **RenderTracks**       | Render stems to `Records\<date>` |

## Installation

Install via [ReaPack](https://reapack.com/) using the Band Record repository, or copy the scripts (and `utils/Utils.lua`) into your REAPER Scripts folder. Add the scripts to the Actions list and assign shortcuts or toolbar buttons as needed.
