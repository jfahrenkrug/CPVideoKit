/*
 * CPVideoView.j
 * CPVideoKit
 *
 * Created by Johannes Fahrenkrug on January 25, 2010.
 * Copyright 2010, Springenwerk All rights reserved.
 */

@import <AppKit/CPWebView.j>


@implementation CPWebView(ScrollFixes) {
    - (void)loadHTMLStringWithoutMessingUpScrollbars:(CPString)aString
    {
        [self _startedLoading];
    
        _ignoreLoadStart = YES;
        _ignoreLoadEnd = NO;
    
        _url = null;
        _html = aString;
    
        [self _load];
    }
}
@end

@implementation CPVideoView : CPWebView
{
    DOMElement      _DOMVideoElement;
    JSObject        _ytPlayer               @accessors(property=ytPlayer);
    BOOL            _playerReady;
    BOOL            _googleAjaxLoaded;
    id delegate @accessors;
    int _percentageLoaded @accessors(property=percentageLoaded);
    int _bytesLoaded @accessors(property=bytesLoaded);
    int _bytesTotal @accessors(property=bytesTotal);
    int _duration @accessors(property=duration);
    int _currentTime @accessors(property=currentTime);
    BOOL hasLoaded;
}

- (id)initWithFrame:(CGRect)aFrame
{
    if (self = [super initWithFrame:aFrame]) {
        var bounds = [self bounds];
        
        [self setFrameLoadDelegate:self];
        console.log(document.location.href.substring(0, document.location.href.lastIndexOf('/')));
        [self setMainFrameURL:document.location.href.substring(0, document.location.href.lastIndexOf('/')) + @"/Frameworks/CPVideoKit/iframe.html"];
    }

    return self;
}

- (void)webView:(CPWebView)aWebView didFinishLoadForFrame:(id)aFrame {
    // this is called twice for some reason
    if(!hasLoaded) {
        [self loadVideoWhenReady];
    }
    hasLoaded = YES;
}

- (void)loadVideoWhenReady() {
    var domWin = [self DOMWindow];
    
    // we need to "wait" until the swfobject is loaded and available...
    if (typeof(domWin.swfobject) === 'undefined') {
        domWin.window.setTimeout(function() {[self loadVideoWhenReady];}, 100);
    } else {
        [self createVideo];
    }
}   

- (void)createVideo
{
    var domWin = [self DOMWindow];
    var ytPlayerReadyCallback = function() 
    {
        if (delegate && [delegate respondsToSelector:@selector(videoViewIsReady:)]) 
        {
            [delegate videoViewIsReady:self];
        }
        _playerReady = YES;
    }

    var updateData = function() 
    {
        console.log('update data');
        [self setDuration:_ytPlayer.getDuration()];
        [self setCurrentTime:_ytPlayer.getCurrentTime()];
        [self setBytesLoaded:_ytPlayer.getVideoBytesLoaded()];
        [self setBytesTotal:_ytPlayer.getVideoBytesTotal()];
        [self setPercentageLoaded:(_bytesLoaded/(_bytesTotal/100.0))];
    };
    
    domWin.onYouTubePlayerReady = function(playerId) {
        _ytPlayer = domWin.document.getElementById("CPVideoViewEmbed");
        domWin.setInterval(updateData, 250);
        //updateytplayerInfo();
        //ytplayer.addEventListener("onStateChange", "onytplayerStateChange");
        //ytplayer.addEventListener("onError", "onPlayerError");
        ytPlayerReadyCallback();
    };
          
    var params = { allowScriptAccess: "always", bgcolor: "#cccccc" };
    // this sets the id of the object or embed tag to 'myytplayer'.
    // You then use this id to access the swf and make calls to the player's API
    var atts = { id: "CPVideoViewEmbed" };
    domWin.swfobject.embedSWF("http://www.youtube.com/apiplayer?enablejsapi=1&border=0playerapiid=ytplayer",
                     "CPVideoViewDiv", "100%", "100%", "8", null, null, params, atts);
}


// functions for the api calls
- (void)loadVideo:(CPString)id
{
    [self loadVideo:id startSeconds:0];
}

- (void)loadVideo:(CPString)id startSeconds:(int)startSeconds
{
    if (_playerReady) 
    {
        _ytPlayer.loadVideoById(id, parseInt(startSeconds));
    }
}

- (void)cueVideo:(CPString)id
{
    [self cueVideo:id startSeconds:0];
}

- (void)cueVideo:(CPString)id startSeconds:(int)startSeconds 
{
    if (_playerReady) 
    {
        _ytPlayer.cueVideoById(id, startSeconds);
    }
}


- (IBAction)play:(id)sender
{
  if (_playerReady) 
  {
    _ytPlayer.playVideo();
  }
}

- (IBAction)pause:(id)sender 
{
    if (_playerReady) 
    {
        _ytPlayer.pauseVideo();
    }
}

- (IBAction)stop:(id)sender
{
    if (_playerReady) 
    {
        _ytPlayer.stopVideo();
    }
}


- (void)setMuted:(BOOL)muted 
{
    if (_playerReady) 
    {
        if (muted)
        {
            _ytPlayer.mute();
        } 
        else
        {
            _ytPlayer.unMute();
        }
    }
}

- (BOOL)isMuted
{
    if (_playerReady && _ytPlayer.isMuted()) 
    {
        return YES;
    }
    
    return NO;
}

- (void)setVolume:(int)newVolume
 {
     if (_playerReady) 
     {
         _ytPlayer.setVolume(newVolume);
     }
}

- (int) volume
{
    if (_playerReady) 
    {
        return _ytPlayer.getVolume();
    }
    
    return 0;
}

- (void)clearVideo
{
    if (_playerReady) 
    {
        _ytPlayer.clearVideo();
    }
}

/*
function getPlayerState() {
  if (ytplayer) {
    return ytplayer.getPlayerState();
  }
}
*/

- (void)seekTo:(int)seconds 
{
    if (_playerReady) 
    {
        _ytPlayer.seekTo(seconds, true);
    }
}

- (void)setFrameSize:(CGSize)aSize
{
    [super setFrameSize:aSize];
    var bounds = [self bounds];

}

/* Overriding CPWebView's implementation */
- (BOOL)_resizeWebFrame {
    var width = [self bounds].size.width,
        height = [self bounds].size.height;

    _iframe.setAttribute("width", width);
    _iframe.setAttribute("height", height);

    [_frameView setFrameSize:CGSizeMake(width, height)];
}

- (void)viewDidMoveToSuperview
{
    [super viewDidMoveToSuperview];
}


- (BOOL)isPlayerReady 
{
    return _playerReady;
}

+ (JSObject)gmNamespace {
    return gmNamespace;
}

@end

