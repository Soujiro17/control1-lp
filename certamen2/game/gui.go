package game

import (
	"github.com/nsf/termbox-go"
)

func DrawBox(height, width int) {

	pressESC := "ESC para salir"

	// Seteamos las esquinas del tablero
	termbox.SetCell(0, 0, rune('┌'), termbox.ColorDefault, termbox.ColorDefault)
	termbox.SetCell(width-1, 0, rune('┐'), termbox.ColorDefault, termbox.ColorDefault)
	termbox.SetCell(0, height-1, rune('└'), termbox.ColorDefault, termbox.ColorDefault)
	termbox.SetCell(width-1, height-1, rune('┘'), termbox.ColorDefault, termbox.ColorDefault)


	// Seteamos el borde superior e inferior del tablero y el mensaje para salir
	for i := 1; i < width-1; i++ {
		if i-1 < len(pressESC) {
			termbox.SetCell(i, 0, rune(pressESC[i-1]), termbox.ColorDefault, termbox.ColorDefault)
		} else {
			termbox.SetCell(i, 0, rune('─'), termbox.ColorDefault, termbox.ColorDefault)
		}
		termbox.SetCell(i, height-1, rune('─'), termbox.ColorDefault, termbox.ColorDefault)
	}

	// Seteamos el borde izquierdo y derecho del tablero
	for i := 1; i < height-1; i++ {
		termbox.SetCell(0, i, rune('│'), termbox.ColorDefault, termbox.ColorDefault)
		termbox.SetCell(width-1, i, rune('│'), termbox.ColorDefault, termbox.ColorDefault)
	}

	// Correr interfaz
	termbox.Flush()
}

// Posicion x, y, string a escribir, foreground (color text)
// background (color fondo texto)
func DrawString(x, y int, str string, fg, bg termbox.Attribute) {
	for pos, char := range str {
		termbox.SetCell(x+pos, y, rune(char), fg, bg)
	}
	termbox.Flush()
}