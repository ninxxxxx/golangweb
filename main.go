package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"

	"github.com/KongZ/golangweb/handlers"
)

// Release a server version
const Release = "0.1"
const w = "0.1"

// How to try it: PORT=8000 go run main.go
func main() {
	log.Printf("Starting the server version %s ...", Release)

	port := os.Getenv("PORT")
	if port == "" {
		log.Fatal("Port is not set.")
	}

	r := handlers.Router(Release)

	interrupt := make(chan os.Signal, 1)
	signal.Notify(interrupt, os.Interrupt, syscall.SIGTERM)

	server := &http.Server{
		Addr:    ":" + port,
		Handler: r,
	}
	go func() {
		log.Fatal(server.ListenAndServe())
	}()
	log.Printf("The server is ready on port %s", port)

	killSignal := <-interrupt
	switch killSignal {
	case os.Interrupt:
		log.Print("Got SIGINT...")
	case syscall.SIGTERM:
		log.Print("Got SIGTERM...")
	}

	log.Print("The server is shutting down...")
	server.Shutdown(context.Background())
	log.Print("Done")
}
