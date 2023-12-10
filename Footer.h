// Enable 'Outgoing Connections (Client)' in App Sandbox.
#import <WebKit/WebKit.h>

class Footer {
    
    private:
    
        bool _init = false;
    
        WKWebViewConfiguration *_webConfiguration = [[WKWebViewConfiguration alloc] init];
        WKUserContentController *_userController = [[WKUserContentController alloc] init];
        WKWebView<WKNavigationDelegate,WKScriptMessageHandler> *_view;
      
    public:
    
        WKWebView *view() {
            return this->_view;
        }
    
        void scale(int v) {
            [this->_view evaluateJavaScript:[NSString stringWithFormat:@"document.getElementById('scale').textContent = %d;",v] completionHandler:nil];
        }
    
        Footer() {
            
            if(objc_getClass("Web")==nil) {
                                
                objc_registerClassPair(objc_allocateClassPair(objc_getClass("WKWebView"),"Web",0));
                Class Web = objc_getClass("Web");

                Utils::addMethod(Web,@"webView:didFinishNavigation:",^(id me, WKWebView *webView, WKNavigation *navigation) {
                    
                    if(this->_init==false) {
                        
                        this->_init = true;
                        
                        [this->_view evaluateJavaScript:@"document.body.setAttribute('oncontextmenu','event.preventDefault();');" completionHandler:nil];
                        [this->_view setAlphaValue:1];
                        
                        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"INITIALIZE" object:nil]];
                    }
                },"v@:@@");
                
                Utils::addMethod(Web,@"userContentController:didReceiveScriptMessage:",^(id me,WKUserContentController *userContentController,WKScriptMessage *message) {
                    if(Utils::isEqString(message.name,@"select")) {
                        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:message.body object:nil]];
                    }
                },"v@:@@");
            }
            
            this->_webConfiguration.userContentController = this->_userController;

            this->_view = (WKWebView<WKNavigationDelegate,WKScriptMessageHandler> *)[[objc_getClass("Web") alloc] initWithFrame:CGRectMake(0,0,STAGE_WIDTH,FOOTER_HEIGHT) configuration:this->_webConfiguration];
            [this->_view setValue:[NSNumber numberWithBool: YES] forKey:@"drawsTransparentBackground"];

            [this->_userController addScriptMessageHandler:this->_view name:@"select"];
            [this->_view setNavigationDelegate:this->_view];
            [this->_view setAlphaValue:0];

            [this->_view loadHTMLString:[NSString stringWithUTF8String:R"(<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title></title>
        <style>

            * {
                margin:0;
                padding:0;
                -webkit-user-select:none;
                cursor:default;
                font-size:14px;
                font-family:Helvetica,sans-serif;
                letter-spacing:0.025em;
                color:#CCC;
            }
            
            #footer {
                width:100%;
                height:32px;
                background:rgba(64,64,64);
            }
          
            #footer > p {
                position:absolute;
                top:0;
                left:calc(100% - 58px);
                text-align:right;
                display:inline-block;
                width:50px;
                line-height:32px;
                -webkit-user-select:none;
                pointer-events:none;
            }
            
        </style>
    </head>
    <body>
        <div id="footer">
            <p><span id="scale">100</span><span style="margin-left:0.075em;">%</span></p>
        </div>
        <script>
        </script>
    </body>
</html>)"] baseURL:nil];
        }
    
        ~Footer() {
            [this->_view removeFromSuperview];
        }
    
};
