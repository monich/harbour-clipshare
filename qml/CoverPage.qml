import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.clipshare 1.0

import "harbour"

CoverBackground {
    id: thisCover

    signal clipboardCleared()

    readonly property bool _haveClipboardText: HarbourClipboard.text.length > 0
    readonly property int _coverActionHeight: Theme.itemSizeSmall/parent.scale

    Label {
        id: label

        text: AppTitle
        horizontalAlignment: Text.AlignHCenter
        color: Theme.highlightColor
        wrapMode: Text.NoWrap
        font.family: Theme.fontFamilyHeading
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            topMargin: Theme.paddingMedium
        }
    }

    Item {
        width: parent.width
        anchors {
            top: label.bottom
            bottom: parent.bottom
            bottomMargin: _coverActionHeight
        }

        HarbourHighlightIcon {
            id: image

            readonly property int _size: parent.width - 2 * Theme.paddingLarge

            sourceSize: Qt.size(_size, _size)
            source: Qt.resolvedUrl("images/share.svg")
            anchors.centerIn: parent
            highlightColor: _haveClipboardText ? Theme.secondaryColor : Theme.secondaryHighlightColor
        }
    }

    CoverActionList {
        enabled: _haveClipboardText
        CoverAction {
            iconSource: "image://theme/icon-cover-cancel"
            onTriggered: {
                HarbourClipboard.text = ""
                thisCover.clipboardCleared()
            }
        }
    }
}
