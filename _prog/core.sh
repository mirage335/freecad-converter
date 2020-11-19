##### Core


# Static parameters. Must be accepted if function overridden to point script contained installation.
_app_command_static() {
	# WARNING: Apparently, freecad ignores or does not use entirely as expected, all variables and command line parameters, related to redirecting the "$HOME"/.FreeCAD directory or subdirectories.
	#mkdir -p "$scriptLocal"/freecad_modules_extra
	#"$appExecutable" --module-path "$scriptLocal"/freecad_modules_extra --user-cfg "$UserParameter" --system-cfg "$SystemParameter" "$@"
	
	[[ ! -e "$appExecutable" ]] && return 1
	[[ "$appExecutable" == "" ]] && return 1
	
	#xmessage -timeout 12 "
	#PWD=$PWD
	#"$appExecutable" "$@"
	#"
	
	"$appExecutable" "$@"
	wait
}

_app_command() {
	[[ "$appExecutable" == "" ]] && type "freecad" >/dev/null 2>&1 && appExecutable=$(type -p freecad)
	#[[ "$appExecutable" == "" ]] && export appExecutable="$scriptLocal"/setups/FreeCAD_0.18-16146-Linux-Conda_Py3Qt5_glibc2.12-x86_64.AppImage
	[[ "$appExecutable" == "" ]] && export appExecutable="$scriptLocal"/setups/FreeCAD_0.19-22039-Linux-Conda_glibc2.12-x86_64.AppImage
	
	_app_command_static "$@"
}

_app() {
	_app_command "$@"
}

_freecad() {
	_app "$@"
}

_freecad-xvfb() {
	xvfb-run "$scriptAbsoluteLocation" _freecad "$@"
}


_request-mesh-freecad() {
	_messagePlain_warn 'Mesh Deviation - 1mm (rough) , 2.50um (manufacturing)'
	_messagePlain_request 'request: FreeCAD: Mesh Workbench: Edit -> Preferences -> Import-Export -> Mesh Formats -> Maximum mesh deviation'
}


#https://gist.github.com/hyOzd/2e75a9816cfabeb5b4aa
_here_freecad_converter-header() {
	cat << CZXWXcRMTo8EmM8i4d
#!/usr/bin/freecad

import sys
#sys.path.insert(0, '/usr/lib/freecad/')
#from FreeCAD import Base
#from math import *

import os

import Part
import Mesh

import FreeCADGui

import ImportGui

CZXWXcRMTo8EmM8i4d
}

_here_freecad_converter-newDocument() {
	cat << CZXWXcRMTo8EmM8i4d
App.newDocument("Unnamed")
App.setActiveDocument("Unnamed")
App.ActiveDocument=App.getDocument("Unnamed")
Gui.ActiveDocument=Gui.getDocument("Unnamed")
Gui.activeDocument().activeView().viewDefaultOrientation()

doc = FreeCAD.activeDocument()

CZXWXcRMTo8EmM8i4d
}

_here_freecad_converter-openDocument() {
	local currentInFile_basename
	currentInFile_basename="Unnamed"
	( [[ "$1" == *'.fcstd' ]] || [[ "$1" == *'.FCSTD' ]] || [[ "$1" == *'.FCStd' ]] ) && currentInFile_basename=$(basename "$1")
	! ( [[ "$1" == *'.fcstd' ]] || [[ "$1" == *'.FCSTD' ]] || [[ "$1" == *'.FCStd' ]] ) && _messagePlain_bad 'fail' && return 1
	currentInFile_basename=${currentInFile_basename//-/_}
	currentInFile_basename=${currentInFile_basename%.*}
	
	
	cat << CZXWXcRMTo8EmM8i4d
FreeCAD.open(u"$1")
App.setActiveDocument("$currentInFile_basename")
App.ActiveDocument=App.getDocument("$currentInFile_basename")
Gui.ActiveDocument=Gui.getDocument("$currentInFile_basename")

doc = FreeCAD.activeDocument()

CZXWXcRMTo8EmM8i4d
}

_here_freecad_converter-objects() {
	cat << CZXWXcRMTo8EmM8i4d

__objs__=[]

#for obj in doc.Objects:
#	if obj.ViewObject.Visibility:
#	    __objs__.append(obj)

for obj in doc.Objects:
	__objs__.append(obj)

CZXWXcRMTo8EmM8i4d
}

_here_freecad_converter-exit() {
	cat << CZXWXcRMTo8EmM8i4d

exit(0)

CZXWXcRMTo8EmM8i4d
}




_here_freecad_converter-ImportGUI_insert() {
	cat << CZXWXcRMTo8EmM8i4d

ImportGui.insert(u"$1","Unnamed")

CZXWXcRMTo8EmM8i4d
}

_here_freecad_converter-ImportGUI_export() {
	cat << CZXWXcRMTo8EmM8i4d

ImportGui.export(__objs__,u"$2")

CZXWXcRMTo8EmM8i4d
}

_here_freecad_converter-Mesh_import() {
	local currentInObject_basename
	currentInObject_basename=$(basename "$1")
	currentInObject_basename=${currentInObject_basename//-/_}
	currentInObject_basename=${currentInObject_basename%.*}
	
	cat << CZXWXcRMTo8EmM8i4d

Mesh.insert(u"$1","Unnamed")

CZXWXcRMTo8EmM8i4d

_safeEcho_newline 'FreeCAD.getDocument("Unnamed").addObject("Part::Feature","'"$currentInObject_basename"'001")'

	cat << CZXWXcRMTo8EmM8i4d
__shape__=Part.Shape()
__shape__.makeShapeFromMesh(FreeCAD.getDocument("Unnamed").getObject("$currentInObject_basename").Mesh.Topology,0.100000)
FreeCAD.getDocument("Unnamed").getObject("ShimFlexiblePreload_8mm001").Shape=__shape__
FreeCAD.getDocument("Unnamed").getObject("ShimFlexiblePreload_8mm001").purgeTouched()
del __shape__


CZXWXcRMTo8EmM8i4d
}

_here_freecad_converter-Mesh_export() {
	cat << CZXWXcRMTo8EmM8i4d

Mesh.export(__objs__,u"$2")

CZXWXcRMTo8EmM8i4d
}

_here_freecad_converter-OBJ_export() {
	cat << CZXWXcRMTo8EmM8i4d

import importOBJ
importOBJ.export(__objs__,u"$2")

CZXWXcRMTo8EmM8i4d
}

_here_freecad_converter-saveDocument() {
	local currentInFile_basename
	currentInFile_basename="Unnamed"
	( [[ "$1" == *'.fcstd' ]] || [[ "$1" == *'.FCSTD' ]] || [[ "$1" == *'.FCStd' ]] ) && currentInFile_basename=$(basename "$1")
	currentInFile_basename=${currentInFile_basename//-/_}
	currentInFile_basename=${currentInFile_basename%.*}
	
	cat << CZXWXcRMTo8EmM8i4d

App.getDocument("$currentInFile_basename").saveAs(u"$2")
Gui.SendMsgToActiveView("Save")
CZXWXcRMTo8EmM8i4d

}



_here_freecad_converter-ImportGui_insert-ImportGui_export() {
	_here_freecad_converter-header "$@"
	_here_freecad_converter-newDocument "$@"
	_here_freecad_converter-ImportGUI_insert "$@"
	_here_freecad_converter-objects "$@"
	_here_freecad_converter-ImportGUI_export "$@"
	_here_freecad_converter-exit "$@"
}
_freecad_converter_sequence-ImportGui_insert-ImportGui_export() {
	_start
	
	_request-mesh-freecad
	
	_here_freecad_converter-ImportGui_insert-ImportGui_export "$@" > "$safeTmp"/converter-temp.py
	chmod u+x "$safeTmp"/converter-temp.py
	_freecad-xvfb "$safeTmp"/converter-temp.py
	
	_stop
}
_freecad_converter-ImportGui_insert-ImportGui_export() {
	"$scriptAbsoluteLocation" _freecad_converter_sequence-ImportGui_insert-ImportGui_export "$@"
}




_here_freecad_converter-ImportGui_insert-Mesh_export() {
	_here_freecad_converter-header "$@"
	_here_freecad_converter-newDocument "$@"
	_here_freecad_converter-ImportGUI_insert "$@"
	_here_freecad_converter-objects "$@"
	_here_freecad_converter-Mesh_export "$@"
	_here_freecad_converter-exit "$@"
}
_freecad_converter_sequence-ImportGui_insert-Mesh_export() {
	_start
	
	_request-mesh-freecad
	
	_here_freecad_converter-ImportGui_insert-Mesh_export "$@" > "$safeTmp"/converter-temp.py
	chmod u+x "$safeTmp"/converter-temp.py
	_freecad-xvfb "$safeTmp"/converter-temp.py
	
	_stop
}
_freecad_converter-ImportGui_insert-Mesh_export() {
	"$scriptAbsoluteLocation" _freecad_converter_sequence-ImportGui_insert-Mesh_export "$@"
}



_here_freecad_converter-multi() {
	_here_freecad_converter-header "$@"
	
	if [[ "$1" == *'.step' ]]
	then
		_here_freecad_converter-newDocument "$@"
		_here_freecad_converter-ImportGUI_insert "$@"
	elif [[ "$1" == *'.stl' ]] || [[ "$1" == *'.obj' ]] || [[ "$1" == *'.amf' ]]
	then
		_here_freecad_converter-newDocument "$@"
		_here_freecad_converter-Mesh_import "$@"
	elif [[ "$1" == *'.fcstd' ]]
	then
		_here_freecad_converter-openDocument "$@"
	else
		return 1
	fi
	
	_here_freecad_converter-objects "$@"
	
	if [[ "$2" == *'.step' ]]
	then
		_here_freecad_converter-ImportGUI_export "$@"
	elif [[ "$2" == *'.stl' ]] || [[ "$2" == *'.amf' ]]
	then
		_here_freecad_converter-Mesh_export "$@"
	elif [[ "$2" == *'.obj' ]]
	then
		_here_freecad_converter-OBJ_export "$@"
	elif [[ "$2" == *'.fcstd' ]]
	then
		_here_freecad_converter-saveDocument "$@"
	else
		return 1
	fi
	
	_here_freecad_converter-exit "$@"
	return 0
}
_freecad_converter_sequence-multi() {
	_start
	
	rm -f "$2" > /dev/null 2>&1
	local currentOutFile_mtl
	currentOutFile_mtl=${2%.*}.mtl
	[[ "$currentOutFile_mtl" != "" ]] && [[ -e "$currentOutFile_mtl" ]] && rm -f "$currentOutFile_mtl" > /dev/null
	
	_messagePlain_nominal 'convert: '"$1"' '"$2"
	#_request-mesh-freecad
	
	if ! _here_freecad_converter-multi "$@" > "$safeTmp"/converter-temp.py
	then
		_stop 1
	fi
	chmod u+x "$safeTmp"/converter-temp.py
	_freecad-xvfb "$safeTmp"/converter-temp.py
	
	_stop
}
_freecad_converter-multi() {
	local currentInFile
	currentInFile=$(_getAbsoluteLocation "$1")
	local currentOutFile
	currentOutFile=$(_getAbsoluteLocation "$2")
	shift
	shift
	#_request-mesh-freecad
	_messagePlain_probe_cmd "$scriptAbsoluteLocation" _freecad_converter_sequence-multi "$currentInFile" "$currentOutFile"
}

_find-freecad_converter() {
	find . -type f -not -iname '*.fcstd.*' -not -iname '*.stp.*' -not -iname '*.step.*' -not -iname '*.stpZ.*' -not -iname '*.stpz.*' -not -iname '*.igs.*' -not -iname '*.iges.*' -not -iname '*.stl.*' -not -iname '*.obj.*' -not -iname '*.amf.*' -name "$1" -exec "$scriptAbsoluteLocation" _freecad_converter-multi {} {}"$2" \;
}

# ATTENTION: Override with 'ops' or similar!
_freecad_converter() {
	_request-mesh-freecad
	sleep 1
	
	#_find-freecad_converter '*.fcstd.' '.fcstd'
	_find-freecad_converter '*.fcstd' '.step'
	_find-freecad_converter '*.fcstd' '.stl'
	_find-freecad_converter '*.fcstd' '.obj'
	
	_find-freecad_converter '*.step' '.fcstd'
	#_find-freecad_converter '*.step' '.step'
	_find-freecad_converter '*.step' '.stl'
	_find-freecad_converter '*.step' '.obj'
	
	_find-freecad_converter '*.stl' '.fcstd'
	_find-freecad_converter '*.stl' '.step'
	#_find-freecad_converter '*.stl' '.stl'
	_find-freecad_converter '*.stl' '.obj'
	
	_find-freecad_converter '*.obj' '.fcstd'
	_find-freecad_converter '*.obj' '.step'
	_find-freecad_converter '*.obj' '.stl'
	#_find-freecad_converter '*.obj' '.obj'
}
_freecad-converter() {
	_freecad_converter "$@"
}





_refresh_anchors_specific() {
	_refresh_anchors_specific_single_procedure _freecad-converter
}


_refresh_anchors_user() {
	_refresh_anchors_user_single_procedure _freecad-converter
}

_associate_anchors_request() {
	return 0
	
	#if type "_refresh_anchors_user" > /dev/null 2>&1
	#then
		#_tryExec "_refresh_anchors_user"
		#return
	#fi
	
	#_messagePlain_request 'association: dir'
	#echo _scope_konsole"$ub_anchor_suffix"
	
	
	#_messagePlain_request 'association: dir, *.FCStd'
	#echo _freecad-assembly2"$ub_anchor_suffix"
	
	#_messagePlain_request 'association: *.FCStd'
	#echo _freecad-assembly2"$ub_anchor_suffix"
	
	#_messagePlain_request 'association: *.FCStd'
	#echo _freecad-assembly4"$ub_anchor_suffix"
}


#duplicate _anchor
_refresh_anchors() {
	#_refresh_anchors_ubiquitous
	
	#cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_app_konsole
	
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_freecad-converter
}





#####^ Core
