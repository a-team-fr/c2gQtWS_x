// ekke (Ekkehard Gentz) @ekkescorner
import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtGraphicalEffects 1.0

import "../pages"
import "../common"

Page {
    id: navPage
    property alias depth: navPane.depth
    property string name: "TrackNavPage"
    // index to get access to Loader (Destination)
    property int myIndex: index

    StackView {
        id: navPane
        anchors.fill: parent
        anchors.leftMargin: unsafeArea.unsafeLeftMargin
        anchors.rightMargin: unsafeArea.unsafeRightMargin
        property string name: "TrackNavPane"
        focus: true

        initialItem: TrackListPage {
            id: initialItem
        }

        Loader {
            id: trackSessionListPageLoader
            property int trackId: -1
            active: false
            visible: false
            source: "../pages/TrackSessionListPage.qml"
            onLoaded: {
                item.trackId = trackId
                navPane.push(item)
                item.init()
            }
        }

        Loader {
            id: speakerDetailPageLoader
            property int speakerId: -1
            active: false
            visible: false
            source: "../pages/SpeakerDetailPage.qml"
            onLoaded: {
                item.speakerId = speakerId
                navPane.push(item)
                item.init()
            }
        }

        Loader {
            id: sessionDetailPageLoader
            property int sessionId: -1
            active: false
            visible: false
            source: "../pages/SessionDetailPage.qml"
            onLoaded: {
                item.sessionId = sessionId
                navPane.push(item)
                item.init()
            }
        }

        Loader {
            id: roomDetailPageLoader
            property int roomId: -1
            active: false
            visible: false
            source: "../pages/RoomDetailPage.qml"
            onLoaded: {
                item.roomId = roomId
                navPane.push(item)
                item.init()
            }
        }


        function pushTrackSessions(trackId) {
            trackSessionListPageLoader.trackId = trackId
            trackSessionListPageLoader.active = true
        }

        // only one Speaker Detail in stack allowed to avoid endless growing stacks
        function pushSpeakerDetail(speakerId) {
            if(speakerDetailPageLoader.active) {
                speakerDetailPageLoader.item.speakerId = speakerId
                var pageStackIndex = findPage(speakerDetailPageLoader.item.name)
                if(pageStackIndex > 0) {
                    backToPage(pageStackIndex)
                }
            } else {
                speakerDetailPageLoader.speakerId = speakerId
                speakerDetailPageLoader.active = true
            }
        }

        function pushSessionDetail(sessionId) {
            if(sessionDetailPageLoader.active) {
                sessionDetailPageLoader.item.sessionId = sessionId
                var pageStackIndex = findPage(sessionDetailPageLoader.item.name)
                if(pageStackIndex > 0) {
                    backToPage(pageStackIndex)
                }
            } else {
                sessionDetailPageLoader.sessionId = sessionId
                sessionDetailPageLoader.active = true
            }
        }

        function pushRoomDetail(roomId) {
            roomDetailPageLoader.roomId = roomId
            roomDetailPageLoader.active = true
        }

        function findPage(pageName) {
            var targetPage = find(function(item) {
                return item.name === pageName;
            })
            if(targetPage) {
                return targetPage.StackView.index
            } else {
                console.log("Page not found in StackView: "+pageName)
                return -1
            }
        }
        function backToPage(targetStackIndex) {
            for (var i=depth-1; i > targetStackIndex; i--) {
                popOnePage()
            }
        }

        function backToRootPage() {
            for (var i=depth-1; i > 0; i--) {
                popOnePage()
            }
        }

        function onConferenceSwitched() {
            navPane.backToRootPage()
            initialItem.init()
        }

        Connections {
            target: appWindow
            onConferenceSwitched: navPane.onConferenceSwitched()
        }

        function popOnePage() {
            var page = pop()
            if(page.name === "trackSessionListPage") {
                trackSessionListPageLoader.active = false
                return
            }
            if(page.name === "SpeakerDetailPage") {
                speakerDetailPageLoader.active = false
                return
            }
            if(page.name === "SessionDetailPage") {
                sessionDetailPageLoader.active = false
                return
            }
            if(page.name === "RoomDetailPage") {
                roomDetailPageLoader.active = false
                return
            }
        } // popOnePage

    } // navPane

    FloatingActionButton {
        visible: navPane.depth > 2
        property string imageName: "/list.png"
        z: 1
        anchors.margins: 20
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        imageSource: "qrc:/images/"+iconOnAccentFolder+imageName
        backgroundColor: accentColor
        onClicked: {
            navPane.backToPage(1)
        }
    } // FAB
    FloatingActionButton {
        visible: navPane.depth === 2
        property string imageName: "/tag.png"
        z: 1
        anchors.margins: 20
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        imageSource: "qrc:/images/"+iconOnAccentFolder+imageName
        backgroundColor: accentColor
        onClicked: {
            navPane.backToRootPage()
        }
    } // FAB

    function destinationAboutToChange() {
        // nothing
    }

    // triggered from BACK KEYs:
    // a) Android system BACK
    // b) Back Button from TitleBar
    function goBack() {
        // check if goBack is allowed
        //
        navPane.popOnePage()
    }

    Component.onDestruction: {
        cleanup()
    }

    function init() {
        console.log("INIT TrackNavPane")
        initialItem.init()
    }
    function cleanup() {
        console.log("CLEANUP TrackNavPane")
    }

} // navPage
