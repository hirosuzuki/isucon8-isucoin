// Package isulogger is client for ISULOG
package isulogger

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"net/url"
	"path"
	"time"
)

// Log はIsuloggerに送るためのログフォーマット
type Log struct {
	// Tagは各ログを識別するための情報です
	Tag string `json:"tag"`
	// Timeはログの発生時間
	Time time.Time `json:"time"`
	// Data はログの詳細情報でTagごとに決められています
	Data interface{} `json:"data"`
}

type Isulogger struct {
	endpoint *url.URL
	appID    string
}

// NewIsulogger はIsuloggerを初期化します
//
// endpoint: ISULOGを利用するためのエンドポイントURI
// appID:    ISULOGを利用するためのアプリケーションID
func NewIsulogger(endpoint, appID string) (*Isulogger, error) {
	u, err := url.Parse(endpoint)
	if err != nil {
		return nil, err
	}
	return &Isulogger{
		endpoint: u,
		appID:    appID,
	}, nil
}

var DefaultLogger *Isulogger

var messages = make(chan Log, 10)

func SendLoop() {
	for true {
		m := <-messages
		ms := []Log{m}
		for len(messages) > 0 && len(ms) < 9 {
			m := <-messages
			ms = append(ms, m)
		}
		DefaultLogger.request("/send_bulk", ms)
	}
}

// Send はログを送信します
func (b *Isulogger) Send(tag string, data interface{}) error {
	messages <- Log{
		Tag:  tag,
		Time: time.Now(),
		Data: data,
	}
	return nil
}

func (b *Isulogger) request(p string, v interface{}) error {
	u := new(url.URL)
	*u = *b.endpoint
	u.Path = path.Join(u.Path, p)

	body := &bytes.Buffer{}
	if err := json.NewEncoder(body).Encode(v); err != nil {
		return fmt.Errorf("logger json encode failed. err: %s", err)
	}

	req, err := http.NewRequest(http.MethodPost, u.String(), body)
	if err != nil {
		return fmt.Errorf("logger new request failed. err: %s", err)
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+b.appID)

	res, err := http.DefaultClient.Do(req)
	if err != nil {
		return fmt.Errorf("logger request failed. err: %s", err)
	}
	defer res.Body.Close()
	bo, err := ioutil.ReadAll(res.Body)
	if err != nil {
		return fmt.Errorf("logger body read failed. err: %s", err)
	}
	if res.StatusCode == http.StatusOK {
		return nil
	}
	return fmt.Errorf("logger status is not ok. code: %d, body: %s", res.StatusCode, string(bo))
}
