package restserver

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestRESTServer_HandleStatus(t *testing.T) {
	s := New(NewConfig())
	rec := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/status", nil)
	s.handleStatus().ServeHTTP(rec, req)
	assert.Equal(t, rec.Body.String(), "status")
}
