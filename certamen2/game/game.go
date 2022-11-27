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
	Height       int
	Width        int
	Snakes       int
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

	// Creamos la serpiente
	snake := Init(height, width, 0)

	// Inicializamos una variable Food que generaremos con comida
	// además de pasarle la altura y la anchura del tablero para
	// no salirnos de este
	food := Food{}
	food.Generate(snake, height, width)

	// Variables de continuidad y crecimiento
	// foodEaten := false
	alive := true
	maxLength := (width - 2) * (height - 2)

	mitad := Coordinates{X: int(math.Floor(float64(width/2 - 1))), Y: int(math.Floor(float64(height/2 - 1)))}

	paused := false

	for { // while true iterar las serpientes o aplicar go func() {}

		// var dX float64 = math.Abs(float64(snake.Positions[0].X) - float64(food.Position.X))
		// var dY float64 = math.Abs(float64(snake.Positions[0].Y) - float64(food.Position.Y))

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

		select {
		case key := <-keyPressed:
			switch key {
			case termbox.KeyEsc:
				break
			case termbox.KeySpace:
				paused = !paused
			}
		default:
			if paused {
				time.Sleep(100 * time.Millisecond)
				continue
			}
			str := fmt.Sprintf("Coords snake: (%v, %v)", snake.Positions[0].X, snake.Positions[0].Y)
			str2 := fmt.Sprintf("Coords food: (%v, %v)", food.Position.X, food.Position.Y)
			str3 := fmt.Sprintf("Direction: %v", snake.Direction)
			str6 := fmt.Sprintf("Mitad tablero (%v, %v)", mitad.X, mitad.Y)

			DrawString(width+10, mitad.Y, str, termbox.ColorWhite, termbox.ColorBlack)
			DrawString(width+10, mitad.Y+1, str2, termbox.ColorWhite, termbox.ColorBlack)
			DrawString(width+10, mitad.Y+2, str3, termbox.ColorWhite, termbox.ColorBlack)

			DrawString(width+10, mitad.Y+6, str6, termbox.ColorWhite, termbox.ColorBlack)

			// Bordes del tablero
			DrawString(1, 1, "X", termbox.ColorWhite, termbox.ColorBlack)
			DrawString(1, height-2, "X", termbox.ColorWhite, termbox.ColorBlack)
			DrawString(width-2, 1, "X", termbox.ColorWhite, termbox.ColorBlack)
			DrawString(width-2, height-2, "X", termbox.ColorWhite, termbox.ColorBlack)

			// Cuando se genera un alimento en la misma fila que la serpiente
			// esta intenta girar por su cola y pierde porque la última posición
			// de la cola está en el mismo eje Y que la cabeza

			// Ejemplo del porqué pasa: food en (30, 28), cabeza en (30,24)
			// quiere decir que snake.Positions[0].X == food.Position.X
			// por lo que entrará en las condicionales de la Y, y en ese
			// momento la serpiente cambia de dirección y choca con su cola.

			if snake.Positions[0].Y != food.Position.Y && food.Position.Y >= mitad.Y {
				snake.Direction = DOWN
			}
			if snake.Positions[0].Y != food.Position.Y && food.Position.Y < mitad.Y {
				snake.Direction = UP
			}
			if snake.Positions[0].X != food.Position.X && food.Position.X >= mitad.X {
				snake.Direction = RIGHT
			}
			if snake.Positions[0].X != food.Position.X && food.Position.X < mitad.X {
				snake.Direction = LEFT
			}

			if snake.FoodEaten { // Si la serpiente se come una fruta
				snake.Grow() // La serpiente crece
				alive = snake.Move(false, options)
				food.Generate(snake, height, width) // Se genera una nueva comida

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

			snake.FoodEaten = false

			// Si la posición de la fruta es la misma que la de
			// la serpiente, es porque se la comieron, por lo tanto
			// foodEaten debe ser true
			if snake.Positions[0].X == food.Position.X && snake.Positions[0].Y == food.Position.Y {
				snake.FoodEaten = true
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
func Init(height, width, row int) Snake {

	snake := Snake{
		Direction: RIGHT,
		Length:    0,
		Positions: []Coordinates{},
		FoodEaten: false,
	}
	snake.Init(height, width, row)

	return snake
}
