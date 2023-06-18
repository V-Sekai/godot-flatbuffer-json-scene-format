# Merge Scene Tool for Godot Editor with FlatBuffer-based JSON Serialization

[![Discord Banner](https://discordapp.com/api/guilds/1067685170397855754/widget.png?style=banner2)](https://discord.gg/SWg6vgcw3F)

**C++ Module WIP. See the gdscript sample.**

## Table of Contents

- [Part 1: Merge Scene Tool](#part-1-merge-scene-tool)
  - [Primary Problem: Merging Scenes in Collaborative Projects](#primary-problem-merging-scenes-in-collaborative-projects)
  - [Solution: Integrate a Merge Scene Tool in Godot Editor](#solution-integrate-a-merge-scene-tool-in-godot-editor)
  - [Reason for Core Integration for Merge Tool](#reason-for-core-integration-for-merge-tool)
- [Part 2: JSON Parser Augmented with FlatBuffer for Serialization and Deserialization](#part-2-json-parser-augmented-with-flatbuffer-for-serialization-and-deserialization)
  - [FlatBuffer-based JSON Scene File Format](#flatbuffer-based-json-scene-file-format)
  - [Solution: Use FlatBuffer-based JSON as Another Easy-to-Read File Format](#solution-use-flatbuffer-based-json-as-another-easy-to-read-file-format)
  - [Open problems](#open-problems)

## Part 1: Merge Scene Tool

### Primary Problem: Merging Scenes in Collaborative Projects

In collaborative projects, team members may edit the same scene in different ways. Version control systems (VCS) like Git can help manage these modifications through merging. However, merging scenes (TSCN format) can be challenging due to their complex semantics and potential for corruption.

### Solution: Integrate a Merge Scene Tool in Godot Editor

To prevent scene corruption after merging, the Godot Editor should provide a merge scene window that allows users to merge TSCN files. This tool should:

1. Detect Git merge conflict placeholders (`<<<<<<<`, `=======`, `>>>>>>>`)
2. Reconstruct local and remote scenes
3. Display a merged scene tree with actions to accept or discard changes, or choose between local and remote versions

The merge tool should be intelligent enough to detect node movements, renaming, and other complex scene semantics. It should also allow users to edit the merged scene before saving it.

### Reason for Core Integration for Merge Tool

While this feature could be implemented as an add-on, a merge tool is a common feature in modern IDEs and should be fully integrated into the Godot Editor for a seamless user experience.

## Part 2: JSON Parser Augmented with FlatBuffer for Serialization and Deserialization

### FlatBuffer-based JSON Scene File Format

FlatBuffer-based JSON is easy to read by tools and people, so developers can understand and work with scene files outside of the Godot Editor. The `fbjscn` format simplifies merging scenes in group projects and lowers the chance of scene corruption.

### Solution: Use FlatBuffer-based JSON as Another Easy-to-Read File Format

To address issues with the current scene file formats (escn, scn, tscn), Godot should support FlatBuffer-based JSON as another easy-to-read file format. FlatBuffers offer faster data conversion compared to normal JSON while maintaining readability. This feature should be part of the main engine to ensure official support and compatibility.

Use `fbjscn` and `fbjres` as the extensions.

### Open problems

1. How do we avoid creating yet another format that adds complexity to the ecosystem?

   - Ensure the new format is backward compatible with existing formats.
   - Provide clear documentation and tooling support for smooth transitions between formats.
   - Avoid exposing the internal format through the saver/loader system, using it only for specific purposes like merging scenes, reducing complexity and allowing users to work with their preferred formats.

1. Implement flatbuffer conversion rather than str_to_var.
