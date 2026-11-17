package main

import (
	"fmt"
	"log/slog"
	"net/http"
	"os"

	"github.com/alfaizuna/wallet-service-go/internal/httpx"
	"github.com/alfaizuna/wallet-service-go/internal/platform/config"
	"github.com/alfaizuna/wallet-service-go/internal/platform/logger"
)

func main() {
	if err := run(); err != nil {
		fmt.Fprintln(os.Stderr, "fatal:", err)
		os.Exit(1)
	}
}

func run() error {
	cfg, err := config.Load()
	if err != nil {
		return fmt.Errorf("load config: %w", err)
	}

	log := logger.New(cfg.Env, cfg.LogLevel)
	slog.SetDefault(log)

	router := httpx.NewRouter(log)

	srv := &http.Server{
		Addr:    cfg.HTTPAddr,
		Handler: router,
	}

	log.Info("api starting", "env", cfg.Env, "addr", cfg.HTTPAddr)
	return srv.ListenAndServe()
}
