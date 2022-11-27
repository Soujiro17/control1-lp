package game

import (
	"fmt"
	"math"
	"time"

	"github.com/nsf/termbox-go"
)

// Las coordenadas contienen la cabeza de la serpiente
type Coordinates struct {
	X int
	Y int
}

// Opciones del juego
type Options struct {
	PacmanEffect bool
	Speed        int
	Height			 int
	Width			 	 int
}

func updateScore(score, height, width int) {
	str := fmt.Sprintf("Puntos: %d", score)
	DrawString(width-1-len(str), height-1, str, termbox.ColorDefault, termbox.ColorDefault)
}

func Play(keyPressed chan termbox.Key, options Options) {

	// Altura y anchura de la interfaz
	height := options.Height
	width := options.Width

	// Limpiamos la terminal
	termbox.Clear(termbox.ColorDefault, termbox.ColorDefault)

	// Dibujamos el tablero con la altura y anchura
	DrawBox(height, width)

	// Actualizamos el score y le pasamos la altura
	// y la anchura del tablero para posicionar el texto
	// del score

	updateScore(0, height, width)

	// Creamos la serpiente
	snake := Init(height, width)

	// Inicializamos una variable Food que generaremos con comida
	// además de pasarle la altura y la anchura del tablero para
	// no salirnos de este
	food := Food{}
	food.Generate(snake, height, width)

	// Variables de continuidad y crecimiento
	foodEaten := false
	alive := true
	maxLength := (width - 2) * (height - 2)

	for {
		if !alive { // Si no estás vivo (o sea, perdiste)
			str := "Perdiste"

			// Obtenemos el centro del tablero
			x := int(math.Floor(float64(width / 2)))
			y := int(math.Floor(float64(height / 2)))

			// Dibujamos el texto que comience en la posición x-(len(str)/2)
			// para que sea precisamente en el centro
			DrawString(x-(len(str)/2), y-1, str, termbox.ColorDefault, termbox.ColorDefault)

			str = "Presiona enter para comenzar un nuevo juego"

			// Lo mismo que el texto de arriba pero 2 líneas
			// más abajo que el otro
			x = int(math.Floor(float64(width / 2)))
			y = int(math.Floor(float64(height/2)) + 2)
			DrawString(x-(len(str)/2), y+1, str, termbox.ColorDefault, termbox.ColorDefault)
			break
		}
		select { // Si sigue vivo
			case key := <-keyPressed: // Tiene que ver con el channel
				switch key {
					case termbox.KeyArrowUp:
						if snake.Direction != DOWN {
							snake.Direction = UP
						}
					case termbox.KeyArrowRight:
						if snake.Direction != LEFT {
							snake.Direction = RIGHT
						}
					case termbox.KeyArrowDown:
						if snake.Direction != UP {
							snake.Direction = DOWN
						}
					case termbox.KeyArrowLeft:
						if snake.Direction != RIGHT {
							snake.Direction = LEFT
						}
					// case termbox.KeyEnter:
					// 	go func() { Play(keyPressed, options) }()
					// 	return
				}
			default:
				if foodEaten { // Si la serpiente se come una fruta
					snake.Grow() // La serpiente crece
					alive = snake.Move(false, options)
					food.Generate(snake, height, width) // Se genera una nueva comida
					updateScore(snake.Length - 1,height, width) // Se actualiza el score

					if snake.Length == maxLength { // Si alcanza el tamaño máximo
						str := "Ganaste!"

						// Centro del tablero
						x := int(math.Floor(float64(width / 2)))
						y := int(math.Floor(float64(height / 2)))

						// Dibujamos el texto que comience en la posición x-(len(str)/2)
						// para que sea precisamente en el centro
						DrawString(x-(len(str)/2), y-1, str, termbox.ColorDefault, termbox.ColorDefault)

						str = "Presiona enter para comenzar un nuevo juego"

						// Lo mismo que el texto de arriba pero 2 líneas
						// más abajo que el otro
						x = int(math.Floor(float64(width / 2)))
						y = int(math.Floor(float64(height/2)) + 2)
						DrawString(x-(len(str)/2), y+1, str, termbox.ColorDefault, termbox.ColorDefault)
						break
					}
				} else {
					alive = snake.Move(true, options)
				}

				foodEaten = false

				// Si la posición de la fruta es la misma que la de
				// la serpiente, es porque se la comieron, por lo tanto
				// foodEaten debe ser true
				if snake.Positions[0].X == food.Position.X && snake.Positions[0].Y == food.Position.Y {
					foodEaten = true
				}

				// TimeSleep de la velocidad
				time.Sleep(25 * time.Millisecond * time.Duration(options.Speed))
		}
	}

	// Si el juego termina, comenzar otro al presionar ENTER
	for {
		key := <-keyPressed
		if key == termbox.KeyEnter {
			go func() { Play(keyPressed, options) }()
			return
		}
	}
}

// Inicializa un nuevo juego
func Init(height, width int) Snake {

	snake := Snake{
		Direction: RIGHT,
		Length:    0,
		Positions: []Coordinates{},
	}
	snake.Init(height, width)

	return snake
}
