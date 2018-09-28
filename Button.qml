import QtQuick 2.7


Rectangle {
	color: "#8f7a66"
	radius: 3
	width: 130
	height: 40
	property alias text: btText.text
	signal clicked()
	Text {
		id: btText
		anchors.centerIn: parent
		color: "#f9f6f2";
		font { pixelSize: 18; bold: true; family: "Clear Sans"}
	}
	MouseArea {
		anchors.fill: parent
		hoverEnabled: true
		onEntered: cursorShape = Qt.PointingHandCursor
		onExited: cursorShape = Qt.ArrowCursor
		onClicked: parent.clicked()
	}
}