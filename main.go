package main

import (
	"bytes"
	"html/template"
	"image"
	"image/png"
	"log"
	"os"

	"github.com/powerslacker/misc/svg"
)

func main() {
	buffer := &bytes.Buffer{}
	writer := buffer

	type Inventory struct {
		Material string
		Count    uint
	}

	sweaters := Inventory{"wool", 17}
	tmpl, err := template.ParseFiles("sample.svg")
	if err != nil {
		panic(err)
	}
	err = tmpl.Execute(writer, sweaters)
	if err != nil {
		panic(err)
	}

	log.Println("done tmpl.Execute")

	size := image.Point{1000, 1000}
	des, err := svg.Render(writer, size)

	// imageBuffer := &bytes.Buffer{}

	log.Println("done svg.Render")

	out, err := os.Create("sample.png")
	if err != nil {
		log.Fatal("failed creating png file", err)
	}

	log.Println("done os.Create")

	err = png.Encode(out, des)
	if err != nil {
		log.Fatal("failed writing png to file", err)
	}

	// file, err := os.Create("sample.png")
	// fmt.Fprintln(file, imageBuffer)

	log.Println("done png.Encode")
}
