package server

import (
	"crypto/tls"
	"io/ioutil"
)

const (
	defaultTlsCrtPath = "/etc/ngrok/tls/ngrok.me/server.crt"
	defaultTlsKeyPath = "/etc/ngrok/tls/ngrok.me/server.key"
)

func LoadTLSConfig(crtPath string, keyPath string) (tlsConfig *tls.Config, err error) {
	fileOrAsset := func(path, defaultPath string) ([]byte, error) {
		if path == "" {
			return ioutil.ReadFile(defaultPath)
		}
		return ioutil.ReadFile(path)
	}

	var (
		crt  []byte
		key  []byte
		cert tls.Certificate
	)

	if crt, err = fileOrAsset(crtPath, defaultTlsCrtPath); err != nil {
		return
	}

	if key, err = fileOrAsset(keyPath, defaultTlsKeyPath); err != nil {
		return
	}

	if cert, err = tls.X509KeyPair(crt, key); err != nil {
		return
	}

	tlsConfig = &tls.Config{
		Certificates: []tls.Certificate{cert},
	}

	return
}
