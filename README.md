# WebRTC_MLKit

[![Build Status](https://travis-ci.com/m10117013/WebRTC_MLKit.svg?branch=master)](https://travis-ci.com/m10117013/WebRTC_MLKit)

## Requirements
* Xcode10

## How to use

1. Start the signaling server:
    1. Navigate to the `signaling` folder.
    2. Run `npm install` to install all dependencies.
    3. Run `node app.js` to start the server.
2. pod install
3. open `workspace`
3. configure your signaling server IP in Config
	1. goto `WWDefaultSignalingClientConfigure.m`
 	2. modify your signaling server Address (Default port is 8080)
		
		> e.g http://172.20.10.3:8080
4. start app



	

