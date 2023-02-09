FROM golang:1.20-bullseye as mini_tiktok_feed_http_builder

WORKDIR /mini_tiktok_feed

RUN apt-get install apt-transport-https ca-certificates -y \
    && mv /etc/apt/sources.list /etc/apt/sources.list.bak \
    && echo 'deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye main contrib non-free' >> /etc/apt/sources.list \
    && echo 'deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-updates main contrib non-free' >> /etc/apt/sources.list \
    && echo 'deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-backports main contrib non-free' >> /etc/apt/sources.list \
    && echo 'deb https://mirrors.tuna.tsinghua.edu.cn/debian-security bullseye-security main contrib non-free' >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get install libprotobuf-dev protobuf-compiler -y \
    && git clone --recurse-submodules https://github.com/sosyz/mini_tiktok_feed.git /mini_tiktok_feed \
    && git submodule update --init --recursive \
    && ls /mini_tiktok_feed/ -lah \
    && protoc /mini_tiktok_feed/Feed/proto/*.proto --go_out=/mini_tiktok_feed/Feed/proto/ --go-grpc_out=/mini_tiktok_feed/Feed/proto/ \
    && go build -o /mini_tiktok_feed/Feed/cmd/http/http /mini_tiktok_feed/Feed/cmd/http/http.go




FROM alpine:latest

WORKDIR /mini_tiktok_feed_http_builder
COPY --from=mini_tiktok_feed_http_builder /mini_tiktok_feed_http_builder/Feed/cmd/http/http ./http

RUN apk update \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && chmod +x ./http \
EXPOSE 8080

ENTRYPOINT ["./http"]