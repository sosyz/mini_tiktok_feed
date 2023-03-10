package main

import "github.com/gin-gonic/gin"

func InitRouter(prefix string) *gin.Engine {
	// add "/" to prefix if prefix is not "/" end
	if prefix != "" &&
		prefix != "/" &&
		prefix[len(prefix)-1] != '/' {
		prefix += "/"
	}

	r := gin.New()
	r.Use(gin.Logger())
	r.Use(gin.Recovery())
	r.Use(AuthdMiddleware())
	{
		douyin := r.Group(prefix + "douyin")

		douyin.GET("feed/", PlayerList)

		{
			publish := douyin.Group("publish/")

			publish.POST("action/", CreateWorks)
			publish.GET("list/", PushList)
		}

		{
			favorite := douyin.Group("favorite/")

			favorite.POST("action/", FavoriteCreate)
			favorite.GET("list/", FavoriteList)
		}
	}
	return r
}
