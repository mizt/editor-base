class Win {
    
    private:
    
        NSWindow *_win = nil;
        
    public:
    
        void addChild(NSView *view) {
            [[this->_win contentView] addSubview:view];
        }
    
        Win() {
            this->_win = [[NSWindow alloc] initWithContentRect:CGRectMake(0,0,STAGE_WIDTH,STAGE_HEIGHT) styleMask:1|1<<2 backing:NSBackingStoreBuffered defer:NO];
            this->_win.backgroundColor =  [NSColor colorWithCalibratedRed:0.5 green:0.5 blue:0.5 alpha:1];
            
            CGSize screenSize = [[NSScreen mainScreen] frame].size;
            CGSize windowSize = this->_win.frame.size;

            [this->_win setFrame:CGRectMake((screenSize.width -windowSize.width)*0.5,(screenSize.height-windowSize.height)*0.5, windowSize.width,windowSize.height) display:YES];
        }
    
        void appear() {
            [this->_win makeKeyAndOrderFront:nil];
        }
       
        ~Win() {
            [this->_win setReleasedWhenClosed:NO];
            [this->_win close];
            this->_win = nil;
        }
};