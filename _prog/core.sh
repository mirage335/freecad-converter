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


_request-mesh-freecad() {
	_messagePlain_warn 'Mesh Deviation - 1mm (rough) , 2.50um (manufacturing)'
	_messagePlain_request 'request: FreeCAD: Mesh Workbench: Edit -> Preferences -> Import-Export -> Mesh Formats -> Maximum mesh deviation'
}


_here_freecad_converter-header() {
	cat << CZXWXcRMTo8EmM8i4d
#!/usr/bin/freecad

import sys
sys.path.insert(0, '/usr/lib/freecad/')
from FreeCAD import Base
from math import *

import os

import Part
import Mesh

import FreeCADGui

import ImportGui

App.newDocument("Unnamed")
App.setActiveDocument("Unnamed")
App.ActiveDocument=App.getDocument("Unnamed")

CZXWXcRMTo8EmM8i4d
}

_here_freecad_converter-objects() {
	cat << CZXWXcRMTo8EmM8i4d

__objs__=[]
for obj in doc.Objects:
	if obj.ViewObject.Visibility:
	    __objs__.append(obj)

CZXWXcRMTo8EmM8i4d
}

_here_freecad_converter-exit() {
	cat << CZXWXcRMTo8EmM8i4d

exit()

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



_here_freecad_converter-Mesh_export() {
	import Mesh
	Mesh.export(__objs__,u"$2")
}




_here_freecad_converter-ImportGui_insert-ImportGui_export() {
	_here_freecad_converter-header "$@"
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
	"$safeTmp"/converter-temp.py
	
	_stop
}
_freecad_converter-ImportGui_insert-ImportGui_export() {
	"$scriptAbsoluteLocation" _freecad_converter_sequence-ImportGui_insert-ImportGui_export "$@"
}




_here_freecad_converter-ImportGui_insert-Mesh_export() {
	_here_freecad_converter-header "$@"
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
	"$safeTmp"/converter-temp.py
	
	_stop
}
_freecad_converter-ImportGui_insert-Mesh_export() {
	"$scriptAbsoluteLocation" _freecad_converter_sequence-ImportGui_insert-Mesh_export "$@"
}



_here_freecad_converter-multi() {
	_here_freecad_converter-header "$@"
	
	if [[ "$1" == *'.step' ]]
	then
		_here_freecad_converter-ImportGUI_insert "$@"
	elif [[ "$1" == *'.stl' ]]
	then
		return 1
	elif [[ "$1" == *'.fcstd' ]]
	then
		return 1
	else
		return 1
	fi
	
	_here_freecad_converter-objects "$@"
	
	if [[ "$2" == *'.step' ]]
	then
		_here_freecad_converter-ImportGUI_export
	elif [[ "$2" == *'.stl' ]]
	then
		_here_freecad_converter-Mesh_export "$@"
	elif [[ "$2" == *'.fcstd' ]]
	then
		return 1
	else
		return 1
	fi
	
	_here_freecad_converter-exit "$@"
	return 0
}
_freecad_converter_sequence-multi() {
	_start
	
	_messagePlain_nominal 'convert: '"$1"' '"$2"
	#_request-mesh-freecad
	
	if ! _here_freecad_converter-multi "$@" > "$safeTmp"/converter-temp.py
	then
		_stop 1
	fi
	chmod u+x "$safeTmp"/converter-temp.py
	"$safeTmp"/converter-temp.py
	
	_stop
}
_freecad_converter-multi() {
	"$scriptAbsoluteLocation" _freecad_converter_sequence-multi "$@"
}


_freecad_converter() {
	find . -type f -name '*.step' -exec "$scriptAbsoluteLocation" _freecad_converter-multi {} {}.fcstd \;
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
