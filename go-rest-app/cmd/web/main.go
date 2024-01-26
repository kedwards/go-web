package main

import (
	"embed"
	"errors"
	"fmt"
	"github.com/go-chi/chi/v5"
	"html/template"
	"net/http"
	"os"
	"strings"
)

var (
	//go:embed templates
	templateFS embed.FS

	pages = map[string]string{
		"/": "index",
	}

	version = "0.0.0"

	hostname = os.Getenv("HOSTNAME")
)


func main() {
	err := runServer()
	if err != nil {
		if errors.Is(err, http.ErrServerClosed) {
			fmt.Println("client server shutdown")
		} else {
			fmt.Println("client server failed", err)
		}
	}
}

func runServer() error {
	httpRouter := chi.NewRouter()

	httpRouter.Get("/", serveIndex)

	server := &http.Server{Addr: ":8888", Handler: httpRouter}
	return server.ListenAndServe()
}

func parse(file string) *template.Template {
  funcs := template.FuncMap{
    "uppercase": func(v string) string {
        return strings.ToUpper(v)
    },
}
	return template.Must(template.New("layout.html").Funcs(funcs).ParseFS(templateFS, "layout.html", file))
}

func parseSingle(file string) (*template.Template, error)  {
  tpl, err := template.ParseFS(templateFS, file)
	if err != nil {
    return nil, err
	}
  return tpl, nil
}

func serveIndex(w http.ResponseWriter, r *http.Request) {
	page, ok := pages[r.URL.Path]
	if !ok {
		w.WriteHeader(http.StatusNotFound)
		return
	}

	templateToRender := fmt.Sprintf("templates/%s.gohtml", page)
	tpl, err := parseSingle(templateToRender)
	if err != nil {
		fmt.Sprintf("page %s not found in pages cache...", r.RequestURI)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	data := map[string]interface{}{
		"userAgent":  r.UserAgent(),
		"version":    version,
		"hostname":   hostname,
	}

	err = tpl.Execute(w, data)
	if err != nil {
		fmt.Println("error executing template", err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
}
