import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Rectangle {
    id: screen
    color: "#0b101a"
    width: 1280
    height: 800

    property color ink: "#f1e9ed"
    property color muted: "#b5bac8"
    property color accent: "#ed7775"
    property bool signingIn: false
    property string feedback: ""

    function submit() {
        if (signingIn || username.text.trim().length === 0 || session.currentIndex < 0)
            return
        feedback = ""
        signingIn = true
        sddm.login(username.text.trim(), password.text, session.currentIndex)
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            screen.signingIn = false
            screen.feedback = "Access denied. Check your username and password."
            password.clear()
            password.forceActiveFocus()
        }
    }

    Image {
        anchors.fill: parent
        source: "bridge.svg"
        fillMode: Image.PreserveAspectCrop
        sourceSize.width: screen.width
        sourceSize.height: screen.height
    }

    component ConsoleField: TextField {
        color: screen.ink
        placeholderTextColor: screen.muted
        selectionColor: "#753b49"
        selectedTextColor: screen.ink
        font.pixelSize: 16
        padding: 12
        background: Rectangle {
            color: "#10141e"
            border.color: parent.activeFocus ? screen.accent : "#535968"
        }
    }

    component ConsoleButton: Button {
        implicitHeight: 40
        contentItem: Text {
            text: parent.text
            color: parent.enabled ? screen.ink : screen.muted
            font.pixelSize: 14
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            color: parent.down ? "#633843" : parent.hovered ? "#3a2936" : "#202430"
            border.color: parent.activeFocus ? screen.accent : "#5c414e"
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width: Math.min(parent.width - 32, 440)
        height: Math.min(parent.height - 28, content.implicitHeight + 48)
        color: "#f4111520"
        border.color: "#62424e"
        clip: true

        Rectangle {
            width: parent.width
            height: 2
            color: screen.accent
        }

        ScrollView {
            anchors.fill: parent
            anchors.margins: 24
            contentWidth: availableWidth

            ColumnLayout {
                id: content
                width: parent.width
                spacing: 10

                Label {
                    text: "IMPERIAL COMMAND"
                    color: screen.accent
                    font.family: "monospace"
                    font.bold: true
                    font.pixelSize: 14
                    font.letterSpacing: 3
                }
                Label {
                    text: "Security checkpoint"
                    color: screen.ink
                    font.pixelSize: 30
                    font.bold: true
                    Layout.bottomMargin: 8
                }
                Label { text: "Username"; color: screen.muted }
                ConsoleField {
                    id: username
                    Layout.fillWidth: true
                    text: userModel.lastUser || ""
                    selectByMouse: true
                    Accessible.name: "Username"
                    onAccepted: password.forceActiveFocus()
                }
                Label { text: "Access code"; color: screen.muted }
                ConsoleField {
                    id: password
                    Layout.fillWidth: true
                    echoMode: TextInput.Password
                    Accessible.name: "Access code"
                    onAccepted: screen.submit()
                }
                Label { text: "Desktop session"; color: screen.muted }
                ComboBox {
                    id: session
                    Layout.fillWidth: true
                    implicitHeight: 40
                    model: sessionModel
                    textRole: "name"
                    currentIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : (count > 0 ? 0 : -1)
                    Accessible.name: "Desktop session"
                    palette.button: "#202430"
                    palette.buttonText: screen.ink
                    palette.base: "#161b27"
                    palette.text: screen.ink
                    palette.highlight: "#753b49"
                    palette.highlightedText: screen.ink
                }
                Label {
                    Layout.fillWidth: true
                    visible: screen.feedback.length > 0
                    wrapMode: Text.WordWrap
                    text: screen.feedback
                    color: screen.accent
                }
                ConsoleButton {
                    Layout.fillWidth: true
                    Layout.topMargin: 4
                    text: screen.signingIn ? "Signing in…" : "Sign in"
                    enabled: !screen.signingIn && username.text.trim().length > 0 && session.currentIndex >= 0
                    onClicked: screen.submit()
                }
                RowLayout {
                    Layout.fillWidth: true
                    ConsoleButton {
                        text: "Restart"
                        visible: sddm.canReboot
                        Layout.fillWidth: true
                        onClicked: sddm.reboot()
                    }
                    ConsoleButton {
                        text: "Shut down"
                        visible: sddm.canPowerOff
                        Layout.fillWidth: true
                        onClicked: sddm.powerOff()
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        if (username.text.length > 0)
            password.forceActiveFocus()
        else
            username.forceActiveFocus()
    }
}
