import QtQuick 2.7

Rectangle {
	color: "#BBADA0"
	radius: 3
	property alias topText: topText.text
	property alias bottomText: bottomText.text
	width: bottomText.contentWidth + 50
	height: topText.contentHeight + bottomText.contentHeight + 15
	Text {
		id: topText
		anchors { top: parent.top; horizontalCenter: parent.horizontalCenter; topMargin: 10 }
		color: "#eee4da"
		font { pixelSize: 13; bold: true; family: "Clear Sans"}
	}
	Text {
		id: bottomText
		anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; bottomMargin: 5 }
		color: "white"
		font { pixelSize: 25; bold: true; family: "Clear Sans"}
	}
}