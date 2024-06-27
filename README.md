# General Scripting and Functions
Generic scripts and functions, written as templates or for portability. I often reference or pull code from here.

## Scripts

* `1PasswordAuditing.sh` is a first pass at automating the process of auditing 1Password for work. Currently you need to manually add in the group names and vaults, and manually format the output to CSV. I haven't gotten to this yet but will update when I do.
* `looper.sh` is a bash script for macOS that runs various tasks between reboots without repeating task groups, and has persistent variables between reboots. I wrote this template to support automated endpoint setup and configuration before DEP/MDM became practically the only way to image.
* `it-functions.sh` is a project I started but never completed. It was designed to run from an MDM for techs on the floor to run various command line functions without needing to remember or even know the command line. While started there are many functions I never got around to writing. That said the menu system, which includes breadcrumbs, might be useful for you as a starting point.
* `parallel_processing.sh` I made this script because sometimes I want a script to do more than one thing at a time. Variations using functions() and && are used, and the trick overall is the shell's use of & to dump processes in the background.
