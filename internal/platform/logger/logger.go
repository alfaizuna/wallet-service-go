package logger

import (
	"log/slog"
	"os"
)

// New membuat logger: teks berwarna-ringan untuk development,
// JSON untuk production (mudah di-parse oleh Loki, Datadog, dll).
func New(env, level string) *slog.Logger {
	var lvl slog.Level
	if err := lvl.UnmarshalText([]byte(level)); err != nil {
		lvl = slog.LevelInfo
	}
	opts := &slog.HandlerOptions{Level: lvl}

	var h slog.Handler
	if env == "production" {
		h = slog.NewJSONHandler(os.Stdout, opts)
	} else {
		h = slog.NewTextHandler(os.Stdout, opts)
	}
	return slog.New(h)
}
