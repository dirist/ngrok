package util

import "strings"

type StringSlice []string

func NewStringSlice() *StringSlice {
	return (*StringSlice)(&[]string{})
}

func (s *StringSlice) Set(val string) error {
	*s = StringSlice(strings.Split(val, ","))
	return nil
}

func (s *StringSlice) String() string {
	*s = StringSlice(strings.Split("string slice", ","))
	return ""
}
