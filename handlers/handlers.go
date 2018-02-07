package handlers

import (
	"log"
	"sync/atomic"
	"time"

	"github.com/gorilla/mux"
)

// Router register necessary routes and returns an instance of a router.
func Router(release string) *mux.Router {
	isReady := &atomic.Value{}
	isReady.Store(false)
	go func() {
		log.Printf("Readiness probe is negative by default...")
		time.Sleep(10 * time.Second)
		isReady.Store(true)
		log.Printf("Readiness probe is positive.")
	}()

	r := mux.NewRouter()
	r.HandleFunc("/version", version(release)).Methods("GET")
	r.HandleFunc("/health", health)
	r.HandleFunc("/content", content)
	r.HandleFunc("/ready", readiness(isReady))
	return r
}
