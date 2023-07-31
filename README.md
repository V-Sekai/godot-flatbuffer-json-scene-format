# Merge Scene Tool for Godot Editor

[![Discord Banner](https://discordapp.com/api/guilds/1067685170397855754/widget.png?style=banner2)](https://discord.gg/SWg6vgcw3F)

## Table of Contents

- [Part 1: Merge Scene Tool](#part-1-merge-scene-tool)
  - [Primary Problem: Merging Scenes in Collaborative Projects](#primary-problem-merging-scenes-in-collaborative-projects)
  - [Solution: Integrate a Merge Scene Tool in Godot Editor](#solution-integrate-a-merge-scene-tool-in-godot-editor)

## Part 1: Merge Scene Tool

### Primary Problem: Merging Scenes in Collaborative Projects

In collaborative projects, team members may edit the same scene in different ways. Version control systems (VCS) like Git can help manage these modifications through merging. However, merging scenes (TSCN format) can be challenging due to their complex semantics and potential for corruption.

### Solution: Integrate a Merge Scene Tool in Godot Editor

To prevent scene corruption after merging, the Godot Editor should provide a merge scene window that allows users to merge TSCN files. This tool should:

1. Detect Git merge conflict placeholders (`<<<<<<<`, `=======`, `>>>>>>>`)
2. Reconstruct local and remote scenes
3. Display a merged scene tree with actions to accept or discard changes, or choose between local and remote versions

The merge tool should be intelligent enough to detect node movements, renaming, and other complex scene semantics. It should also allow users to edit the merged scene before saving it.