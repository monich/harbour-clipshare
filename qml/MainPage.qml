import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.clipshare 1.0

import "harbour"

Page {
    id: thisPage

    // If we are jailed, we may not be able to determine the declarative-transferengine-qt5 version
    readonly property string _sharingApiVersion: HarbourSystemInfo.packageVersion("declarative-transferengine-qt5")
    readonly property bool _sailfishShare: HarbourProcessState.jailedApp || HarbourSystemInfo.compareVersions(_sharingApiVersion, "0.4.0") >= 0 // QML API break
    readonly property bool _haveTextInClipboard: HarbourClipboard.text !== ""
    readonly property bool _landscapeLayout: isLandscape && Screen.sizeCategory < Screen.Large
    readonly property real _topNotchHeight: ('topCutout' in Screen) ? Screen.topCutout.height : 0
    readonly property real _cornerRadius: Math.max(('topLeftCorner' in Screen) ? Screen.topLeftCorner.radius : 0, Theme.paddingMedium)
    property bool _completed
    property var _shareAction

    Component.onCompleted: _completed = true

    Rectangle {
        id: clipboardTextContainer

        x: Theme.horizontalPageMargin
        width: parent.width - 2 * x
        anchors {
            top: parent.top
            bottom: shareButton.top
            topMargin: Math.max(orientation == Orientation.Portrait ? (_topNotchHeight + Theme.paddingMedium) : 0, Theme.paddingLarge)
            bottomMargin: Theme.paddingLarge
        }
        radius: _cornerRadius
        color: Theme.rgba(Theme.highlightBackgroundColor, 0.1)
        border {
            color: Theme.rgba(Theme.highlightColor, Theme.opacityLow)
            width: Math.max(2, Math.floor(Theme.paddingSmall/3))
        }

        SilicaFlickable {
            id: clipboardTextFlickable

            readonly property real _margin: Math.max(Theme.paddingLarge, _cornerRadius)

            anchors.fill: parent
            contentHeight: clipboardTextLabel.height + 2 * _margin
            visible: _haveTextInClipboard
            clip: true

            Label {
                id: clipboardTextLabel

                x: Theme.horizontalPageMargin
                y: clipboardTextFlickable._margin
                width: parent.width - 2 * x
                horizontalAlignment: Text.AlignLeft
                wrapMode: Text.Wrap
                text: HarbourClipboard.text
                color: Theme.highlightColor
            }

            VerticalScrollDecorator {
                id: scrollBar

                Component.onCompleted: {
                    if ('margin' in scrollBar) {
                        // This property appeared in SFOS 4.4
                        scrollBar.margin = clipboardTextFlickable._margin
                    }
                }
            }
        }

        OpacityRampEffect {
            sourceItem: clipboardTextFlickable
            direction: 'BothEnds' in OpacityRamp ? OpacityRamp.BothEnds : OpacityRamp.TopToBottom
            offset: 1 - clipboardTextFlickable._margin/clipboardTextFlickable.height
            slope: clipboardTextFlickable.height/clipboardTextFlickable._margin
        }

        InfoLabel {
            id: noTextInClipboardLabel

            opacity: (_completed && !_haveTextInClipboard) ? 1 : 0
            visible: opacity > 0
            anchors.fill: parent
            verticalAlignment: Text.AlignVCenter

            //: Info label
            //% "No text in clipboard"
            text: _haveTextInClipboard ? "" : qsTrId("clipshare-info-clipboard_empty")

            Behavior on opacity { FadeAnimation {} }
        }
    }

    Button {
        id: shareButton

        //: Button label
        //% "Share"
        text: qsTrId("clipshare-button-share")
        enabled: _haveTextInClipboard
        anchors {
            bottom: parent.bottom
            bottomMargin: Theme.paddingLarge
        }
        onClicked: {
            if (_sailfishShare) {
                if (!_shareAction) {
                    _shareAction = Qt.createQmlObject("import Sailfish.Share 1.0; ShareAction {}",
                        thisPage, "SailfishShare")
                }
                if (_shareAction) {
                    _shareAction.resources = [{ "data": HarbourClipboard.text }]
                    //: Sharing page header
                    //% "Share text"
                    _shareAction.title = qsTrId("clipshare-title-share_text")
                    _shareAction.trigger()
                }
            } else {
                pageStack.push(legacySharingPage, { "content": { "data": HarbourClipboard.text } })
            }
        }
    }

    Component {
        id: legacySharingPage

        Page {
            allowedOrientations: thisPage.allowedOrientations

            property alias content: methodList.content

            HarbourShareMethodList {
                id: methodList

                anchors.fill: parent
                model: HarbourTransferMethodsModel
                //: Sharing method list item
                //% "Add account"
                addAccountText: qsTrId("clipshare-button-add_account")

                header: PageHeader {
                    //: Sharing page header
                    //% "Share text"
                    title: qsTrId("clipshare-title-share_text")
                }

                VerticalScrollDecorator {}
            }
        }
    }

    states: [
        State {
            name: "portrait"
            when: !_landscapeLayout
            changes: [
                AnchorChanges {
                    target: shareButton
                    anchors {
                        right: undefined
                        horizontalCenter: parent.horizontalCenter
                    }
                }
            ]
        },
        State {
            name: "landscape"
            when: _landscapeLayout
            changes: [
                AnchorChanges {
                    target: shareButton
                    anchors {
                        right: clipboardTextContainer.right
                        horizontalCenter: undefined
                    }
                }
            ]
        }
    ]
}
