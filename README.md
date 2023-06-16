# Merge Scene Tool for Godot Editor with FlatBuffer-based JSON Serialization

[![Discord Banner](https://discordapp.com/api/guilds/1067685170397855754/widget.png?style=banner2)](https://discord.gg/SWg6vgcw3F)

## Table of Contents

- [Primary Problem: Merging Scenes in Collaborative Projects](#primary-problem-merging-scenes-in-collaborative-projects)
- [Solution: Integrate a Merge Scene Tool in Godot Editor](#solution-integrate-a-merge-scene-tool-in-godot-editor)
  - [FlatBuffer-based JSON Serialization for Merge Tool State](#flatbuffer-based-json-serialization-for-merge-tool-state)
- [Reason for Core Integration for Merge Tool](#reason-for-core-integration-for-merge-tool)
- [FlatBuffer-based JSON Scene File Format](#flatbuffer-based-json-scene-file-format)
  - [Solution: Use FlatBuffer-based JSON as Another Easy-to-Read File Format](#solution-use-flatbuffer-based-json-as-another-easy-to-read-file-format)
- [Open problems](#open-problems)

## Primary Problem: Merging Scenes in Collaborative Projects

In collaborative projects, team members may edit the same scene in different ways. Version control systems (VCS) like Git can help manage these modifications through merging. However, merging scenes (TSCN format) can be challenging due to their complex semantics and potential for corruption.

## Solution: Integrate a Merge Scene Tool in Godot Editor

To prevent scene corruption after merging, the Godot Editor should provide a merge scene window that allows users to merge TSCN files. This tool should:

1. Detect Git merge conflict placeholders (`<<<<<<<`, `=======`, `>>>>>>>`)
2. Reconstruct local and remote scenes
3. Display a merged scene tree with actions to accept or discard changes, or choose between local and remote versions

The merge tool should be intelligent enough to detect node movements, renaming, and other complex scene semantics. It should also allow users to edit the merged scene before saving it.

### FlatBuffer-based JSON Serialization for Merge Tool State

To ensure efficient serialization of the internal state of the merge tool at the start, in between, and at the end, FlatBuffer-based JSON should be used. This will allow for faster processing and better performance while maintaining human-readability.

## Reason for Core Integration for Merge Tool

While this feature could be implemented as an add-on, a merge tool is a common feature in modern IDEs and should be fully integrated into the Godot Editor for a seamless user experience.

## FlatBuffer-based JSON Scene File Format

FlatBuffer-based JSON is easy to read by tools and people, so developers can understand and work with scene files outside of the Godot Editor.

The `fbjscn` format helps people work together on projects by making it easier to use tools like Git. This makes merging scenes in group projects simpler and lowers the chance of scene corruption.

When working on a project related to Godot, like making games or add-ons, you might encounter problems with the current scene file formats (escn, scn, tscn):

- **escn**: For scenes made by other tools (like importing from Blender)
- **scn**: Binary format, small but not very helpful when working together on a project
- **tscn**: Text format, INI/TOML-like syntax, easy to read, and good to use

The TSCN format is special and not used a lot, causing issues such as difficulty editing scenes outside of the Godot Editor and lacking helpful tools like linters or syntax checkers.

### Solution: Use FlatBuffer-based JSON as Another Easy-to-Read File Format

To fix these problems, it would be beneficial for Godot to support other easy-to-read file formats, like FlatBuffer-based JSON. FlatBuffers are a faster way to convert data into a different form compared to normal JSON while still being easy to read.

This feature should be part of the main engine to ensure it has official support and works well together.

Use `fbjscn` and `fbjres` as the extensions.

### Open problems

1. How do we avoid creating yet another format that adds complexity to the ecosystem?

   - One possible solution is to ensure that the new format is backward compatible with existing formats.
   - Another approach is to provide clear documentation and tooling support to help developers transition smoothly between formats.
   - Additionally, we can avoid exposing the internal format through the saver/loader system, keeping it hidden from users and only using it for specific purposes like merging scenes. This way, the complexity of managing multiple formats is reduced, and users can continue working with their preferred formats without being affected by the internal format.

### Converting JSON to Godot Types With FlatBuffers

**Error handling**: Handling errors during JSON parsing can be challenging, as it may require implementing custom error handling logic. FlatBuffers provide built-in error handling mechanisms, making it easier to detect and handle issues during the conversion process.

**Type safety**: JSON data is loosely typed, which can lead to type-related issues when converting it to Godot types. FlatBuffers enforce strict typing, ensuring that the resulting Godot types have the correct types and reducing the likelihood of runtime errors.

By using FlatBuffer-based JSON serialization, these difficulties can be mitigated, providing a more efficient and reliable way to convert JSON data to Godot types.