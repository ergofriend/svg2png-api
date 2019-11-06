package main

import (
	"bytes"
	"html/template"
	"image"
	"image/png"
	"log"
	"os"

	"github.com/rogpeppe/misc/svg"
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

	// hello := fmt.Sprint(writer)

	// hello := bufio.NewWriter(writer)

	// file, err := os.Open(hello)
	// if err != nil {
	// 	log.Fatal("failed reading svg", err)
	// }
	// defer file.Close()

	size := image.Point{1000, 1000}
	des, err := svg.Render(writer, size)

	out, err := os.Create("sample.png")
	if err != nil {
		log.Fatal("failed creating png file", err)
	}

	err = png.Encode(out, des)
	if err != nil {
		log.Fatal("failed writing png to file", err)
	}

	log.Println("done")
}
