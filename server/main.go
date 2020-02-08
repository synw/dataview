package main

import (
	"fmt"
	"io"
	"net/http"
	"os"

	"github.com/labstack/echo"
	"github.com/labstack/echo/middleware"
)

func upload(c echo.Context) error {
	fmt.Println("Upload handler")
	file, err := c.FormFile("file")
	if err != nil {
		fmt.Println("Error receiving file")
		return err
	}
	if file == nil {
		fmt.Println("Nil file")
	} else {
		fmt.Println("File:")
		fmt.Println(file)
	}
	fmt.Println("Opening ", file.Filename)
	src, err := file.Open()
	if err != nil {
		return err
	}
	defer src.Close()

	// Destination
	dst, err := os.Create(file.Filename)
	if err != nil {
		return err
	}
	defer dst.Close()

	// Copy
	if _, err = io.Copy(dst, src); err != nil {
		return err
	}

	return c.HTML(http.StatusOK, fmt.Sprintf("<p>File %s uploaded successfully", file.Filename))
}

func main() {
	e := echo.New()

	e.Use(middleware.Logger())
	e.Use(middleware.Recover())

	e.Static("/", "public")
	e.POST("/upload", upload)

	e.Logger.Fatal(e.Start(":8082"))
}
