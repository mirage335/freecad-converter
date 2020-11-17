Copyright (C) 2020 mirage335
See the end of the file for license conditions.
See license.txt for freecad-converter license conditions.

CAD model converter using FreeCAD. Mostly intended to convert FreeCAD/STEP/STL libraries to STEP/STL/OBJ formats used by special CAD/graphics engines.

Specifically developed in the hope of converting FreeCAD assemblies, OpenBuilds STEP model library, and similar, to formats used by VR CAD assembly tools like MakeVR Pro and Gravity Sketch .

# Usage

From a directory with CAD models to convert...

./_freecad-converter

Keep in mind this will *recusively* convert all CAD models found under this directory.

As usual, ubiquitous_bash features may be used to install 'shortcuts' to ~/bin , install/test dependencies, etc.

./ubiquitous_bash.sh _test

./ubiquitous_bash.sh _setup

./ubiquitous_bash.sh _anchor


# Design

Bash 'heredoc' is used to create a temporary python script, which the normal 'freecad' binary can run with full GUI functionality, under 'xvfb' so the GPU does not interfere with other uses of the computer desktop.

Function '_freecad-converter' is defined under '_prog/core.sh' .

Code is intentionally kept fairly simple and self-explanatory. Any code/functions/variables placed in 'ops' or 'ops.sh' files will be 'included' by ubiquitous_bash.sh near the end of the script, overriding any code concatenated by 'compile.sh' .


# Safety

DANGER: Recursive program . Use with as much care as 'rm' or any other recursive delete/modify program .


__Copyright__
This file is part of freecad-converter.

freecad-converter is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

freecad-converter is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with freecad-converter.  If not, see <http://www.gnu.org/licenses/>.
