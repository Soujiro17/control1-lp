package game

import (
	"math/rand"
	"time"

	"github.com/nsf/termbox-go"
)

// Food contains all the food information
type Food struct {
	Position Coordinates
}

// Generate generates a new food item for the snake to eat
func (f *Food) Generate(snake Snake, height int, width int) {
	rand.Seed(time.Now().UnixNano())
	pos := Coordinates{
		X: rand.Intn(width-2) + 1,
		Y: rand.Intn(height-2) + 1,
	}
	for _, c := range snake.Positions {
		if c.X == pos.X && c.Y == pos.Y {
			f.Generate(snake, height, width)
			return
		}
	}

	f.Position = pos
	termbox.SetCell(f.Position.X, f.Position.Y, rune('•'), termbox.ColorRed, termbox.ColorDefault)
	termbox.Flush()
}
