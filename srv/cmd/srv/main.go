package main

import (
	"log"
	"net/http"
	"os"
)

func main() {
	dir := http.Dir("./static")
	http.Handle("/", http.FileServer(dir))
	log.Println("starting server, listening on :" + os.Getenv("PORT"))
	err := http.ListenAndServe(":"+os.Getenv("PORT"), nil)
	if err != nil {
		log.Fatalf("%w", err)
	}
}
