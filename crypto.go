package main

// Helpers for two-way encryption with a secret key.

import (
	"encoding/base64"

	"github.com/kevinburke/nacl"
	"github.com/kevinburke/nacl/secretbox"
)

func opaqueByte(b []byte, secretKey nacl.Key) string {
	out := secretbox.EasySeal(b, secretKey)
	return base64.URLEncoding.EncodeToString(out)
}

func unopaqueByte(compressed string, secretKey nacl.Key) ([]byte, error) {
	encrypted, err := base64.URLEncoding.DecodeString(compressed)
	if err != nil {
		return nil, err
	}
	return secretbox.EasyOpen(encrypted, secretKey)
}

// Opaque encrypts s with secretKey and returns the encrypted string encoded
// with base64, or an error.
func opaque(s string, secretKey *[32]byte) string {
	return opaqueByte([]byte(s), secretKey)
}

// Unopaque decodes compressed using base64, then decrypts the decoded byte
// array using the secretKey.
func unopaque(compressed string, secretKey *[32]byte) (string, error) {
	b, err := unopaqueByte(compressed, secretKey)
	if err != nil {
		return "", err
	}
	return string(b), nil
}
