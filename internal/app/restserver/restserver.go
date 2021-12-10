package restserver

import (
	"io"
	"net/http"

	"github.com/gorilla/mux"
	"github.com/sirupsen/logrus"
)

type RESTServer struct {
	config *Config
	logger *logrus.Logger
	router *mux.Router
}

func New(config *Config) *RESTServer {
	return &RESTServer{
		config: config,
		logger: logrus.New(),
		router: mux.NewRouter(),
	}
}

func (s *RESTServer) Start() error {
	if err := s.congifureLogger(); err != nil {
		return err
	}
	s.congifureRouter()
	s.logger.Info("starting REST API server")
	return http.ListenAndServe(s.config.BindAddr, s.router)
}

func (s *RESTServer) congifureLogger() error {
	level, err := logrus.ParseLevel(s.config.LogLevel)
	if err != nil {
		return err
	}
	s.logger.SetLevel(level)
	return err
}

func (s *RESTServer) congifureRouter() {
	s.router.HandleFunc("/status", s.handleStatus())
}

func (s *RESTServer) handleStatus() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		io.WriteString(w, "status")
	}
}
