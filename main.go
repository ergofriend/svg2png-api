package main

import (
	"bytes"
	"html/template"
	"image"
	"image/png"
	"log"
	"net/http"

	"github.com/labstack/echo"
)

// Quiz ...
type Quiz struct {
	QuizName string
	Option1  string
	Option2  string
	Option3  string
}

func main() {
	tmpl, err := template.ParseFiles("templates/test2.svg")
	if err != nil {
		panic(err)
	}

	e := echo.New()
	e.GET("/", func(c echo.Context) error {
		return c.Blob(http.StatusOK, "image/png", renderImage(tmpl))
	})
	e.Logger.Fatal(e.Start(":1323"))
}

func renderImage(template *template.Template) []byte {
	buffer := &bytes.Buffer{}
	writer := buffer

	quiz := Quiz{"問2", "旧石器時代", "新石器時代", "縄文時代"}

	err := template.Execute(writer, quiz)
	if err != nil {
		panic(err)
	}

	size := image.Point{1000, 1000}
	des, err := util.RenderSVG(writer, size)

	imageBuffer := &bytes.Buffer{}

	err = png.Encode(imageBuffer, des)
	if err != nil {
		log.Fatal("failed writing png to file", err)
	}

	return imageBuffer.Bytes()
}
