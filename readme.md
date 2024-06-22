Telescope extension for searching and opening git diffs

## What is this?

This is basically a wrapper for telescope bultin git_status with a custom select action.

It lets you browse git diffs of the current directory and open them in a new unmodifiable buffer.

## Why did i do this?

Because the builtin git_status select action opens the file instead of the diff and i wanted a way to open diffs easily without making my config uglier by setting a custom selector for git_status

## How to install

For lazy:
```
{"leonnelc/git_diff.nvim"}
```
and then load it with
```
require("telescope").load_extension("git_diff")
```
# Usage
Use it like any other telescope picker
```
:Telescope git_diff
```
or calling the lua function
```
require("telescope").extensions.git_diff.git_diff()
```
