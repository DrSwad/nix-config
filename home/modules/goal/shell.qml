import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
  id: root
  property string goalText: ""
  property string goalState: "error"

  Process {
    id: watcher
    running: true
    command: ["@goal@", "watch"]
    stdout: SplitParser {
      onRead: line => {
        const o = JSON.parse(line)
        root.goalText = o.text
        root.goalState = o.state
      }
    }
    onExited: restart.start()
  }

  Timer {
    id: restart
    interval: 2000
    onTriggered: watcher.running = true
  }

  Process {
    id: switcher
    command: ["@goal@", "switch"]
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      required property var modelData
      screen: modelData
      anchors { top: true; right: true }
      margins { top: 4; right: 8 }
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: WlrLayer.Top
      WlrLayershell.namespace: "goal"
      color: "transparent"
      implicitWidth: label.implicitWidth + 20
      implicitHeight: label.implicitHeight + 8

      Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: "#cc1a1a1a"

        Text {
          id: label
          anchors.centerIn: parent
          text: root.goalText
          font.family: "JetBrainsMono Nerd Font"
          font.pixelSize: 13
          color: ({ running: "#a6e3a1", over: "#f38ba8", idle: "#9399b2", error: "#f9e2af" })[root.goalState] ?? "#cdd6f4"
        }

        MouseArea {
          anchors.fill: parent
          onClicked: switcher.startDetached()
        }
      }
    }
  }
}
