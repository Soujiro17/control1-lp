package game

import (
	"github.com/nsf/termbox-go"
	"golang.org/x/exp/slices"
)

// Direction is the type that reppresents the current direction of the snake
type Direction uint8

// UP means that the snake is going up
// RIGHT means that the snake is going right
// DOWN means that the snake is going down
// LEFT means that the snake is going left
const (
	UP    Direction = 0
	RIGHT Direction = 1
	DOWN  Direction = 2
	LEFT  Direction = 3
)

// Snake contains all the snake information
type Snake struct {
	Direction Direction
	Length    int
	Positions []Coordinates
	FoodEaten bool
}

func (s *Snake) SnakeContains(coordenada Coordinates) bool {

	if slices.Contains(s.Positions, coordenada) {
		return true
	}

	return false
}

// Snake is crashing
func (s *Snake) IsCrashing() (bool, bool, bool, bool) {

	var boolLeft, boolRight, boolUp, boolDown bool

	left := Coordinates{
		X: s.Positions[0].X - 1,
		Y: s.Positions[0].Y,
	}

	right := Coordinates{
		X: s.Positions[0].X + 1,
		Y: s.Positions[0].Y,
	}

	up := Coordinates{
		X: s.Positions[0].X,
		Y: s.Positions[0].Y + 1,
	}
	down := Coordinates{
		X: s.Positions[0].X,
		Y: s.Positions[0].Y - 1,
	}

	if s.SnakeContains(left) {
		boolLeft = true
	}

	if s.SnakeContains(right) {
		boolRight = true
	}

	if s.SnakeContains(up) {
		boolUp = true
	}

	if s.SnakeContains(down) {
		boolDown = true
	}

	return boolLeft, boolRight, boolUp, boolDown
}

// Move is the function that moves a snake
func (s *Snake) Move(deleteTail bool, options Options) bool {

	height := options.Height
	width := options.Width

	previousPosition := Coordinates{
		X: s.Positions[0].X,
		Y: s.Positions[0].Y,
	}

	termbox.SetCell(s.Positions[0].X, s.Positions[0].Y, rune('•'), termbox.ColorGreen, termbox.ColorDefault)
	// Delete tail
	if deleteTail {
		termbox.SetCell(s.Positions[s.Length-1].X, s.Positions[s.Length-1].Y, rune(' '), termbox.ColorGreen, termbox.ColorDefault)
	}

	crushedAgainstWall := false
	// Move head
	switch s.Direction {
	case UP:
		s.Positions[0].Y--
		if s.Positions[0].Y == 0 {
			if options.PacmanEffect {
				s.Positions[0].Y = height - 2
			} else {
				crushedAgainstWall = true
			}
		}
		// En estas lineas se asignan los colores de la serpiente y la forma
		termbox.SetCell(s.Positions[0].X, s.Positions[0].Y, rune('▴'), termbox.ColorGreen, termbox.ColorDefault)
	case DOWN:
		s.Positions[0].Y++
		if s.Positions[0].Y == height-1 {
			if options.PacmanEffect {
				s.Positions[0].Y = 1
			} else {
				crushedAgainstWall = true
			}
		}
		termbox.SetCell(s.Positions[0].X, s.Positions[0].Y, rune('▾'), termbox.ColorGreen, termbox.ColorDefault)
	case LEFT:
		s.Positions[0].X--
		if s.Positions[0].X == 0 {
			if options.PacmanEffect {
				s.Positions[0].X = width - 2
			} else {
				crushedAgainstWall = true
			}
		}
		termbox.SetCell(s.Positions[0].X, s.Positions[0].Y, rune('◂'), termbox.ColorGreen, termbox.ColorDefault)
	case RIGHT:
		s.Positions[0].X++
		if s.Positions[0].X == width-1 {
			if options.PacmanEffect {
				s.Positions[0].X = 1
			} else {
				crushedAgainstWall = true
			}
		}
		termbox.SetCell(s.Positions[0].X, s.Positions[0].Y, rune('▸'), termbox.ColorGreen, termbox.ColorDefault)

	}
	termbox.Flush()

	if crushedAgainstWall {
		return false
	}
	// Update coordinates
	length := s.Length
	if deleteTail {
		length--
	}
	for i := 1; i < s.Length; i++ {
		// Current position (s.Positions[i]++)
		partCurrentPosition := Coordinates{
			X: s.Positions[i].X,
			Y: s.Positions[i].Y,
		}
		// Previous position (s.Positions[i])
		s.Positions[i].X = previousPosition.X
		s.Positions[i].Y = previousPosition.Y
		previousPosition.X = partCurrentPosition.X
		previousPosition.Y = partCurrentPosition.Y
		if s.Positions[0].X == s.Positions[i].X && s.Positions[0].Y == s.Positions[i].Y {
			return false
		}
	}

	return true
}

// Grow is the functions that makes the snake growing
func (s *Snake) Grow() {
	x := s.Positions[s.Length-1].X
	y := s.Positions[s.Length-1].Y
	s.Positions = append(s.Positions, Coordinates{X: x, Y: y})
	s.Length++
	termbox.Flush()
}

// Init initializes the snake's head
func (s *Snake) Init(height, width, row int) {
	s.Length = 1
	s.Positions = append(s.Positions, Coordinates{X: (width / 2) + row, Y: height / 2})
	termbox.SetCell(s.Positions[0].X+row, s.Positions[0].Y, rune('•'), termbox.ColorGreen, termbox.ColorDefault)
	termbox.Flush()
}
