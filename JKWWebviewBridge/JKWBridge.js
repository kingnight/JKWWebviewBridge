var console = {};
console.log = function(msg) {
    if (typeof enableLog != 'undefined') {
        window.webkit.messageHandlers.consoleHandler.postMessage(msg);
    }
};
(function() {
    var JSBridge = window.webkit.messageHandlers;
 
	var sendMessageQueue = []
	var messageHandlers = {}
	
	var responseCallbacks = {}   //record callback
	var uniqueId = 1

	function send(data, responseCallback) {
		_doSend({ data:data }, responseCallback)
	}
	
	function registerHandler(handlerName, handler) {
		messageHandlers[handlerName] = handler
	}
	
	function callHandler(handlerName, data, responseCallback) {
		_doSend({ handlerName:handlerName, data:data }, responseCallback)
	}
	
	function _doSend(message, responseCallback) {
		if (responseCallback) {
			var callbackId = 'cb_'+(uniqueId++)+'_'+new Date().getTime()
			responseCallbacks[callbackId] = responseCallback
			message['callbackId'] = callbackId
		}
        JSBridge.sendMsgHandler.postMessage(JSON.stringify(message));
	}

    //objc--javascript
	function _handleMessageFromObjC(messageJSON) {
		setTimeout(function _timeoutDispatchMessageFromObjC() {
			var message = JSON.parse(messageJSON)
			var handler
			var responseCallback

			if (message.responseId) {
				responseCallback = responseCallbacks[message.responseId]
				if (!responseCallback) { return; }
				responseCallback(message.responseData)
				delete responseCallbacks[message.responseId]
			} else {
				if (message.callbackId) {
					var callbackResponseId = message.callbackId
					responseCallback = function(responseData) {
						_doSend({ responseId:callbackResponseId, responseData:responseData })
					}
				}
				
				if (message.handlerName) {
                   handler = messageHandlers[message.handlerName];
				}
				
				try {
                   console.log(message.data);
					handler(message.data, responseCallback)
				} catch(exception) {
					if (typeof console != 'undefined') {
						console.log("WebViewJavascriptBridge: WARNING: javascript handler threw.", message, exception)
					}
				}
			}
		})
	}

	window.WebViewJavascriptBridge = {
		send: send,
		registerHandler: registerHandler,
		callHandler: callHandler,
        _handleMessageFromObjC:_handleMessageFromObjC
	}

	var readyEvent = document.createEvent('Events');
	readyEvent.initEvent('WebViewJavascriptBridgeReady');
	document.dispatchEvent(readyEvent);
 
    var WebViewJavascriptBridge = window.WebViewJavascriptBridge;
})();