package handlers

import (
	"fmt"
	"io/ioutil"
	"net/http"
)

// content returns a simple HTTP handler function which writes a text response.
func content(w http.ResponseWriter, _ *http.Request) {
	w.Header().Set("Content-Type", "text/plain")
	text, err := ioutil.ReadFile("/data/content.txt")
	if err != nil {
		w.Write([]byte(fmt.Sprintf("Unable to load file %v", err)))
	} else {
		w.Write([]byte(text))
	}
}
