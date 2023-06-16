# Merge Scene Tool for Godot Editor with FlatBuffer-based JSON Serialization

[![Discord Banner](https://discordapp.com/api/guilds/1067685170397855754/widget.png?style=banner2)](https://discord.gg/SWg6vgcw3F)

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

When working on a project related to Godot, like making games or add-ons, you might find problems with the current scene file formats (escn, scn, tscn):

- **escn**: For scenes made by other tools (like importing from Blender)
- **scn**: Binary format, small but not very helpful when working together on a project
- **tscn**: Text format, INI/TOML-like syntax, easy to read, and good to use

The TSCN format is special and not used a lot, causing issues like trouble editing scenes outside of the Godot Editor and not having helpful tools like linters or syntax checkers.

### Solution: Use FlatBuffer-based JSON as Another Easy-to-Read File Format

To fix these problems, it would be good for Godot to support other easy-to-read file formats, like FlatBuffer-based JSON. FlatBuffers are a faster way to change data into a different form compared to normal JSON while still being easy to read.

This feature should be part of the main engine to make sure it has official support and works well together.

Use `fbjscn` and `fbjres` as the extensions.

### Open problem

1. How do we not create yet another format?