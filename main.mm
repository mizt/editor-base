#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import <Metal/Metal.h>
#import <objc/runtime.h>

#import <algorithm>

#define STAGE_WIDTH 1280
#define STAGE_HEIGHT 720
#define FOOTER_HEIGHT 32
#define FPS 30.0

#import "Utils.h"
#import "Win.h"
#import "Footer.h"

class App {
    
    private:
        
        Win *_win = nullptr;
        NSView *_view = nil;
    
        Footer *_footer = nullptr;
    
        bool _isDrag = false;
        bool _isDrop = false;
    
        float _zoom = 100.f;
    
        dispatch_source_t _timer;
    
        void addEventListener(NSString *type, void (^on)(NSNotification *)) {
            [[NSNotificationCenter defaultCenter]
                addObserverForName:type
                object:nil
                queue:[NSOperationQueue mainQueue]
                usingBlock:on
            ];
        }
    
    public:
    
        App() {
            
            this->_win = new Win();
            if(objc_getClass("View")==nil) { objc_registerClassPair(objc_allocateClassPair(objc_getClass("NSView"),"View",0)); }
            
            Class View = objc_getClass("View");

            if(View) {
                
                Utils::addMethod(View,@"mouseDown:",^(id me, NSEvent *theEvent) {
                    this->_isDrag = true;
                    NSLog(@"mouseDown:");
                },"v@:@");
                
                Utils::addMethod(View,@"mouseUp:",^(id me, NSEvent *theEvent) {
                    this->_isDrag = false;
                    NSLog(@"mouseUp:");
                },"v@:@");
                
                Utils::addMethod(View,@"scrollWheel:",^(id me, NSEvent *theEvent) {
                    this->_zoom-=theEvent.deltaY*5.0;
                    this->_zoom = std::clamp(this->_zoom,25.f,200.f);
                    if(this->_footer) this->_footer->scale(this->_zoom);
                },"v@:@");
                
                Utils::addMethod(View,@"draggingEntered:",^NSDragOperation(id me,id<NSDraggingInfo> sender) {
                    if(!this->_isDrop) return NSDragOperationNone;
                    return NSDragOperationLink;
                },"@@:@");

                Utils::addMethod(View,@"performDragOperation:",^BOOL(id me, id<NSDraggingInfo> sender) {
                    return this->_isDrop?YES:NO;
                },"@@:@");
                
                Utils::addMethod(View,@"concludeDragOperation:",^(id me, id<NSDraggingInfo> sender) {
                    this->_isDrop = false;
                    dispatch_async(dispatch_get_main_queue(),^{
                        this->_isDrop = true;
                    });
                },"v@:@");
                
                this->_view = (NSView *)[[View alloc] initWithFrame:CGRectMake(0,0,STAGE_WIDTH,STAGE_HEIGHT)];
                [this->_view registerForDraggedTypes:[NSArray arrayWithObjects:NSPasteboardTypeFileURL,nil]];
                this->_view.wantsLayer = YES;
                this->_view.layer.backgroundColor = [NSColor colorWithCalibratedRed:0.5 green:0.5 blue:0.5 alpha:1].CGColor;
              
                this->_win->addChild(this->_view);
                
                this->_footer = new Footer();
                this->_win->addChild(this->_footer->view());

                this->_timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,0,0,dispatch_queue_create("ENTER_FRAME",0));
                dispatch_source_set_timer(this->_timer,dispatch_time(0,0),(1.0/FPS)*1000000000.0,0);
                dispatch_source_set_event_handler(this->_timer,^{
                    
                });
                if(this->_timer) dispatch_resume(this->_timer);
                
                addEventListener(@"INITIALIZE",^(NSNotification *notification) {
                    this->_win->appear();
                });
            }
        }
        
        ~App() {
            if(this->_timer){
                dispatch_source_cancel(this->_timer);
                this->_timer = nil;
            }
            [this->_view removeFromSuperview];
            delete this->_footer;
            delete this->_win;
        }
};

#pragma mark AppDelegate
@interface AppDelegate:NSObject <NSApplicationDelegate> {
    App *app;
    NSMenuItem *quitMenuItem;
}
@end

@implementation AppDelegate
-(void)applicationDidFinishLaunching:(NSNotification*)aNotification {
    app = new App();
    
    id menu = [[NSMenu alloc] init];
    id rootMenuItem = [[NSMenuItem alloc] init];
    [menu addItem:rootMenuItem];
    id appMenu = [[NSMenu alloc] init];
    
    quitMenuItem = [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@"q"];
    [appMenu addItem:[NSMenuItem separatorItem]];
    [appMenu addItem:quitMenuItem];

    
    [rootMenuItem setSubmenu:appMenu];
    [NSApp setMainMenu:menu];
}
-(void)applicationWillTerminate:(NSNotification *)aNotification {
    delete app;
}
@end

int main(int argc, char *argv[]) {
    @autoreleasepool {
        srand(CFAbsoluteTimeGetCurrent());
        srandom(CFAbsoluteTimeGetCurrent());
        id app = [NSApplication sharedApplication];
        id delegat = [AppDelegate alloc];
        [app setDelegate:delegat];
        [app run];
    }
}
