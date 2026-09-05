import QtQuick 2.0
import Sailfish.Silica 1.0

ApplicationWindow {
    id: appWindow

    allowedOrientations: Orientation.Portrait | Orientation.LandscapeMask

    property Page _mainPage

    initialPage: Component {
        MainPage {
            id: mainPage

            allowedOrientations: appWindow.allowedOrientations
            Component.onCompleted: _mainPage = mainPage
        }
    }

    cover: Component {
        CoverPage {
            onClipboardCleared: pageStack.pop(_mainPage, PageStackAction.Immediate)
        }
    }
}
