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


# Workarounds

As exported, OBJ files may not include complete color information, as might be expected from typical STEP format ('with colors') export results. This may be due to assemblies created with 'a2plus' and similar not separately including every shape, among other possible causes. In any case, by default, complete color information is not guaranteed with OBJ export, partly because this would involve code that may be unreliable/complicated, and also because the results may be ultimately undesirable where only a single part is exported in most cases.

Complex assemblies may be exported to OBJ with complete color information...

* Latest FreeCAD compiled from repository source code required - 6e60870ebcb2df018adb7a1281c00dde87750f11 has been tested with full TazIntermediate model .
* Select 'Part' workbench. Select all desired parts/shapes. Click icon to create 'Compound'.
* Select 'Mesh Design' workbench. Select previously created 'Compound'. From top menu bar, 'Meshes -> Create mesh from shape'.
* Meshing options - Standard, 1mm 'surface deviation', 15deg 'angular deviation', YES (checked) to 'Apply face colors to mesh', YES (checked) to 'Define segments by face colors' . Click 'OK'.
* Hide previously created 'Compound'. Colors should still be visible, included on mesh object.
* Select resulting mesh object. From top menu bar, 'Meshes -> Export mesh'. Save as type 'Alias Mesh (*.obj).

Beware the resulting file may not show color information in some programs, such as MeshLab, but will in others, such as GravitySketch. Additionally, although the same format would not result in a '.mtl' file from the 'File -> Export' menu, in this case, it should.



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
