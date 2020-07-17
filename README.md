# General Scripting and Functions
Generic scripts and functions, written as templates or for portability. I often reference or pull code from here.

## Scripts

* `looper.sh` is a bash script for macOS that runs various tasks between reboots without repeating task groups, and has persistent variables between reboots. I wrote this template to support automated endpoint setup and configuration before DEP/MDM became practically the only way to image.
* `it-functions.sh` is a project I started but never completed. It was designed to run from an MDM for techs on the floor to run various command line functions without needing to remember or even know the command line. While started there are many functions I never got around to writing. That said the menu system, which includes breadcrumbs, might be useful for you as a starting point.