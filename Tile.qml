import QtQuick 2.7

Cell {
	property int value: 2
	color: colorChanger()
	property var mergedWith: null

	Text {
		anchors.centerIn: parent
		text: value
		font { pixelSize: value < 100 ? 55 : value < 1000 ? 45 : 35; family: "Clear Sans"; bold: true }
		color: value < 8 ? "#796b5e" : "#f9f6f1"
	}

	SequentialAnimation on scale {
		id: mergeAnim
		PauseAnimation {
			duration: 100
		}
		ScriptAction { script: {value *= 2; z = 1;} }
		NumberAnimation {
			from: 0
			to: 1
			duration: 200
			easing.type: Easing.OutBack
		}
		ScriptAction { script: { mergedWith.destroy(); mergedWith = null; z = 0;} }
		running: false
	}

	NumberAnimation on scale {
		id: appearAnim
		from: 0
		to: 1
		duration: 200
		easing.type: Easing.OutSine
	}

	NumberAnimation on x {
		id: xAnim
		duration: 100
		onToChanged: this.start()
		easing.type: Easing.InOutQuad
	}
	
	NumberAnimation on y {
		id: yAnim
		duration: 100
		onToChanged: this.start()
		easing.type: Easing.InOutQuad
	}

	function completeAnim() {
		xAnim.complete()
		yAnim.complete()
		mergeAnim.complete()
		appearAnim.complete()
	}

	function moveTo(cell) {
		xAnim.to = cell.x
		yAnim.to = cell.y
	}

	function mergeWith(tile) {
		mergedWith = tile
		mergeAnim.start()
	}

	function colorChanger() {
		var value = this.value
		if (value == 2)
			return "#f3e5d7"
		else if (value == 4)
			return "#f2e1c3"
		else if (value == 8)
			return "#feac6d"
		else if (value == 16)
			return "#ff8d56"
		else if (value == 32)
			return "#ff7150"
		else if (value == 64)
			return "#ff5023"
		else if (value == 128)
			return "#EDCF72"
		else if (value == 256)
			return "#EDCC61"
		else if (value == 512)
			return "#EDC850"
		else if (value == 1024)
			return "#EDC53F"
		else if (value == 2048)
			return "#EDC22E"
	}

	function isEqual(tile) {
		return value == tile.value
	}
}