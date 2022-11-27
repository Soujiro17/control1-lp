package main

import (
	"flag"
	"snake/game"

	"github.com/nsf/termbox-go"
)

func main() {
	err := termbox.Init()
	if err != nil {
		panic(err)
	}
	
	defer termbox.Close()

	// Argumentos del programa
	height := flag.Int("height", 30, "altura del tablero (int)")
	width := flag.Int("width", 50, "anchura del tablero (int)")
	speed := flag.Int("speed", 3, "velocidad de la serpiente (1-5) (más rápido a más lento) (int)")
	pacmanEffect := flag.Bool("pacman", true, "efecto pacman (que traspase paredes) (bool)")
	

	flag.Parse()

	keyPressed := make(chan termbox.Key)

	// Configuración del juego
	gameOptions := game.Options{
		PacmanEffect: *pacmanEffect,
		Speed:        *speed, // 1-5 (más rápido al más lento)
		Height: 			*height,
		Width:				*width,
	}
	
	go game.Play(keyPressed, gameOptions)

	exit := false
	
	for {
		if exit {
			break
		}

		switch ev := termbox.PollEvent(); ev.Type {
			case termbox.EventKey:
				switch ev.Key {
				case termbox.KeyEsc:
					exit = true
				case
					termbox.KeyArrowUp,
					termbox.KeyArrowDown,
					termbox.KeyArrowRight,
					termbox.KeyArrowLeft,
					termbox.KeyEnter,
					termbox.KeySpace:
					keyPressed <- ev.Key
				}
		}
	}
}
