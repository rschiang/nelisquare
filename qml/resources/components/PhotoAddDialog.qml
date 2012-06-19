import Qt 4.7
import QtMobility.gallery 1.1

Rectangle {
    signal uploadPhoto(string photo)

    property string checkinID: ""
    property string venueID: ""

    id: photoAddDialog
    width: parent.width
    height: parent.height
    state: "hidden"

    ListModel {
        id: emptyModel
    }

    DocumentGalleryModel {
        id: galleryModel

        autoUpdate: true
        scope: DocumentGallery.Image  //real
        properties: [ "filePath" ]    //real
        //rootType: DocumentGallery.Image //Sim
        //properties: [ "fileName" ]      //Sim
        filter: GalleryWildcardFilter {
            property: "fileName";
            value: "*.jpg";
        }
        sortProperties: [ "-lastModified" ]
    }

    Component {
         id: photoDelegate
         ProfilePhoto {
            photoUrl: model.filePath      //real
            //photoUrl: model.fileName        //sim
            photoSize: photoGrid.cellWidth
            //photoSourceSize: photoGrid.cellWidth //commented due to sizing bug
            photoBorder: 2
            photoSmooth: false
            photoAspect: Image.PreserveAspectFit
            onClicked: {
                photoAddDialog.uploadPhoto(photoUrl);
            }
         }
     }

    GridView {
        id: photoGrid
        width: parent.width
        height: parent.height
        cellWidth: Math.min((width-5)/3,height)
        cellHeight: cellWidth
        clip: true
        model: emptyModel
        delegate: photoDelegate
        header: Text {
            text: "Select photo for upload"
            font.pixelSize: 24
        }
    }

    onStateChanged: {
        if (state == "shown") {
            photoGrid.model = galleryModel;
        } else {
            photoGrid.model = emptyModel;
        }
    }

    states: [
        State {
            name: "hidden"
            PropertyChanges {
                target: photoAddDialog
                x: -parent.width
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: photoAddDialog
                x: 0
            }
        }
    ]

    transitions: [
        Transition {
            from: "shown"
            SequentialAnimation {
                PropertyAnimation {
                    target: photoAddDialog
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
                ScriptAction {
                    script: {
                        photoAddDialog.visible = false;
                        photoGrid.model = emptyModel;
                    }
                }
            }
        },
        Transition {
            to: "shown"
            SequentialAnimation {
                ScriptAction {
                    script: {
                        photoAddDialog.visible = true;
                        photoGrid.model = galleryModel;
                    }
                }
                PropertyAnimation {
                    target: photoAddDialog
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
            }
        }
    ]
}
