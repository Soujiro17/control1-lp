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

	height := options.Height
	width := options.Width

	termbox.Clear(termbox.ColorDefault, termbox.ColorDefault)
	DrawBox(height, width)
	updateScore(0, height, width)


	Init(width, height)
	snake := Init(width, height)

	food := Food{}
	food.Generate(snake, height, width)
	foodEaten := false
	alive := true
	paused := false
	maxLength := (width - 2) * (height - 2)
	for {
		if !alive {
			str := "Perdiste"
			x := int(math.Floor(float64(width / 2)))
			y := int(math.Floor(float64(height / 2)))
			DrawString(x-(len(str)/2), y-1, str, termbox.ColorDefault, termbox.ColorDefault)
			str = "Presiona enter para comenzar un nuevo juego"
			x = int(math.Floor(float64(width / 2)))
			y = int(math.Floor(float64(height/2)) + 2)
			DrawString(x-(len(str)/2), y+1, str, termbox.ColorDefault, termbox.ColorDefault)
			break
		}
		select {
			case key := <-keyPressed:
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
			case termbox.KeySpace:
				paused = !paused
			case termbox.KeyEnter:
				go func() { Play(keyPressed, options) }()
				return
			}
			default:
				if paused {
					time.Sleep(100 * time.Millisecond)
					continue
				}
				if foodEaten {
					snake.Grow()
					alive = snake.Move(false, options)
					food.Generate(snake, height, width)
					updateScore(snake.Length - 1, height, width)
					if snake.Length == maxLength {
						str := "Ganaste!"
						x := int(math.Floor(float64(width / 2)))
						y := int(math.Floor(float64(height / 2)))
						DrawString(x-(len(str)/2), y-1, str, termbox.ColorDefault, termbox.ColorDefault)
						str = "Presiona enter para comenzar un nuevo juego"
						x = int(math.Floor(float64(width / 2)))
						y = int(math.Floor(float64(height/2)) + 2)
						DrawString(x-(len(str)/2), y+1, str, termbox.ColorDefault, termbox.ColorDefault)
						break
					}
				} else {
					alive = snake.Move(true, options)
				}
				foodEaten = false
				if snake.Positions[0].X == food.Position.X && snake.Positions[0].Y == food.Position.Y {
					foodEaten = true
				}
				time.Sleep(25 * time.Millisecond * time.Duration(options.Speed))
		}
	}
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
