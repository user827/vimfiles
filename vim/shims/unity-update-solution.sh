#!/bin/sh
set -eu

project_path=.
if [ ! -f "$project_path/ProjectSettings/ProjectVersion.txt" ]; then
  echo "Not in project root" >&2
  exit 1
fi
unity_version=$(grep m_EditorVersion: "$project_path/ProjectSettings/ProjectVersion.txt" | cut -d' '  -f2)
TERM="xterm" "$HOME/Unity/Hub/Editor/$unity_version/Editor/Unity" -projectPath "${project_path}" -batchmode -quit -logFile - -executeMethod "UnityEditor.SyncVS.SyncSolution" -buildTarget "$1"
