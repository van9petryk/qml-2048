import QtQuick 2.7
import QtQuick.Window 2.11

Window {
	width: gridParent.width + 50
	height: 675
	
	maximumHeight: height
    maximumWidth: width

    minimumHeight: height
    minimumWidth: width
	
	Rectangle {
		width: parent.width
		height: parent.height
		
		color: "#FAF8EF"

		Item {
			anchors { fill: parent; margins: 25 }
			Text {
				id: title
				anchors { left: parent.left; top: parent.top; topMargin: 20; }
				text: "2048"
				color: "#776e65";
				font { pixelSize: 40; bold: true; family: "Clear Sans"}
			}

			Score {
				id: current
				anchors { right: best.left; top: parent.top; rightMargin: 5 }
				topText: "SCORE"
				bottomText: gridParent.score
				Text {
					id: scoreStepText
					x: parent.width/2 - contentWidth/2
					property var stepScore : 0
					font { pixelSize: 25; bold: true; family: "Clear Sans"}
					color: "#776e65"
					opacity: 0
					text: "+" + stepScore
					function updateStepScore(score) {
						stepScore = score
						moveAnim.restart()
						opacityAnim.restart()
					}

					NumberAnimation on y {
						id: moveAnim
						from: 25
						to: -30
						duration: 1000
						running: false
					}
					NumberAnimation on opacity {
						id: opacityAnim
						from: 1
						to: 0
						easing.type: Easing.InQuart
						duration: 1000
						running: false
					}
				}
			}

			Score {
				id: best
				anchors { right: parent.right; top: parent.top }
				topText: "BEST"
				bottomText: gridParent.bestScore
			}

			Item {
				id: above
				anchors { top: title.bottom; topMargin: 20; left: parent.left; right: parent.right; }
				height: newGame.height
				Text {
					id: intro
					anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
					verticalAlignment: Text.AlignVCenter
					font { pixelSize: 16; family: "Clear Sans"}
					text: "Join the numbers and get to the <b>2048 tile!</b>"
				}

				Button {
					id: newGame
					anchors { right: parent.right }
					text: "New Game"
					onClicked: gridParent.startNewGame()
				}
			}

			Rectangle {
				id: gridParent
				anchors { top: above.botom; bottom: parent.bottom; }
				width: childrenRect.width
				height: childrenRect.height
				color: "#C3AB98"

				Rectangle {
					id: gameOver
					visible: false
					anchors.fill: parent
					color: gridParent.won ? Qt.rgba(0.93, 0.76, 0.18, 0.5) : Qt.rgba(0.93, 0.89, 0.85, 0.73)
					z: 2
					opacity: 0
					onVisibleChanged: {
						if (visible)
							opacityGameOverAnim.start()
						else
							opacity = 0
					}
					SequentialAnimation on opacity {
						id: opacityGameOverAnim
						PauseAnimation {
							duration: 1000
						}
						NumberAnimation {
							from: 0
							to: 1
							duration: 500
						}
						running: false
					}
					Text {
						anchors { bottom: restart.top; bottomMargin: 30; horizontalCenter: parent.horizontalCenter }
						text: gridParent.won ? "You Win!" : "Game Over!"
						font { pixelSize: 60; bold: true; family: "Clear Sans"}
						color: gridParent.won ? "#f9f6f2" : "#776e65"
					}
					Button {
						id: restart
						anchors.centerIn: parent
						text: "Try Again"
						onClicked: gridParent.startNewGame()
					}

				}

				Grid {
					id: grid
					padding: 15
					spacing: 15
					Repeater {
						id: repeater
						model: 16
						Cell {}
					}
				}
				focus: true
				
				Component.onCompleted: {
					cells = new Array(16);
					startNewGame();
				}

				SequentialAnimation {
					id: newTileAnim
					PauseAnimation {
						duration: 100
					}
					ScriptAction { script:
						{
							gridParent.addNewTile();
							if (gridParent.isGameOver()) {
								gridParent.focus = false
								gameOver.visible = true
							}
						}
					}
					running: false
				}
				
				Keys.onPressed: {
					var h_shift, v_shift, sign;
					if (event.key == Qt.Key_Left) {
						h_shift = 0
						v_shift = 1
						sign = 1
					}
					else if (event.key == Qt.Key_Right){
						h_shift = 3
						v_shift = 1
						sign = -1
					}
					else if (event.key == Qt.Key_Up) {
						h_shift = 0
						v_shift = 4
						sign = 1
					}
					else if (event.key == Qt.Key_Down) {
						h_shift = 3
						v_shift = 4
						sign = -1
					}
					else
						return

					newTileAnim.complete();
					if (gameOver.visible)
						return

					for (var i = 0; i < 16; i++)
						if (cells[i] != null)
							cells[i].completeAnim();

					var moveOccured  = false;
					var stepScore = 0
					for (var i = 0; i < 4; i++) {
						for (var j = 1; j < 4; j++) {
							var from = (h_shift + j * sign) * v_shift + i * 4 / v_shift;
							if (cells[from] != null) {
								var to = -1
								for (var k = 1; k < j + 1; k++) {
									var nextTo = from - sign * v_shift * k;
									if (cells[nextTo] == null)
										to = nextTo
									else {
										if (cells[nextTo].isEqual(cells[from]) && cells[nextTo].mergedWith == null){
											to = nextTo
											cells[from].mergeWith(cells[to])
											if (cells[from].value * 2 == 2048)
												won = true
											stepScore += cells[from].value * 2
										}
										break
									}
								}
								if (to == -1)
									continue
								cells[from].moveTo(repeater.itemAt(to))
								cells[to] = cells[from]
								cells[from] = null
								moveOccured = true;
							}
						}
					}
					if (moveOccured) {
						newTileAnim.start()
						if (stepScore != 0){
							score += stepScore
							scoreStepText.updateStepScore(stepScore)

						}
					}
				}
				
				property var tileComponent: Qt.createComponent("Tile.qml")
				property var cells
				property var score: 0
				property var bestScore: 0
				property var won
				
				function getEmptyCellIndex() {
					var emptyCells = [];
					for (var i = 0; i < 16; i++) {
						if (cells[i] == null)
							emptyCells.push(i);
					}
					return emptyCells[Math.floor(Math.random() * emptyCells.length)];
				}
				
				function getCellCoord(idx) {
					var cell = repeater.itemAt(idx);
					return {x : cell.x, y : cell.y};
				}

				function startNewGame() {
					gridParent.focus = true
					won = false
					if (score > bestScore)
						bestScore = score
					score = 0
					gameOver.visible = false
					for (var i = 0; i < 16; i++) {
						if (cells[i] != null) {
							cells[i].destroy();
							cells[i] = null;
						}
					}
					addNewTile();
					addNewTile();
				}

				function addNewTile() {
					var idx = getEmptyCellIndex();
					var value = Math.random() < 0.9 ? 2 : 4
					cells[idx] = tileComponent.createObject(gridParent, getCellCoord(idx));
					cells[idx].value = value;
				}

				function isGameOver() {
					if (won)
						return true
					for (var i = 0; i < 16; i++)
						if (cells[i] == null)
							return false;
					for (var i = 0; i < 4; i++) {
						for (var j = 1; j < 4; j++) {
							var hFrom = j + i * 4;
							var hTo = hFrom - 1;
							var vFrom = j * 4 + i;
							var vTo = vFrom - 4;
							if (cells[hFrom].isEqual(cells[hTo]) || cells[vFrom].isEqual(cells[vTo]))
								return false;
						}
					}
					return true;
				}
			}
		}
	}
}