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

	height := flag.Int("height", 30, "an int")
	width := flag.Int("width", 50, "an int")

	flag.Parse()

	keyPressed := make(chan termbox.Key)
	gameOptions := game.Options{
		PacmanEffect: true,
		Speed:        3, // 1-5 (más rápido al más lento)
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
