/*
 * CPVideoView.j
 * CPVideoKit
 *
 * Created by Johannes Fahrenkrug on January 25, 2010.
 * Copyright 2010, Springenwerk All rights reserved.
 */

@import <AppKit/CPWebView.j>
@import "CPYouTubeVideoPlayer.j"
@import "CPVimeoVideoPlayer.j"

CPVideoKitServiceYouTube = 0;
CPVideoKitServiceVimeo = 1;


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
    BOOL            _playerReady;
    BOOL            _googleAjaxLoaded;
    id delegate @accessors;    
    BOOL hasLoaded;
    int _service;
    id _player @accessors(property=player);;
}

- (id)initWithFrame:(CGRect)aFrame
{
    return [self initWithFrame:aFrame service:CPVideoKitServiceYouTube];
}

- (id)initWithFrame:(CGRect)aFrame service:(int)aService
{
    if (self = [super initWithFrame:aFrame]) {
        var bounds = [self bounds];

        _service = aService;
        if (_service == CPVideoKitServiceYouTube)
        {
            _player = [[CPYouTubeVideoPlayer alloc] init];
            [_player setDelegate:self];
        }
        else if (_service == CPVideoKitServiceVimeo)
        {
            _player = [[CPVimeoVideoPlayer alloc] init];
            [_player setDelegate:self];
        }
        
        [self setFrameLoadDelegate:self];
        [self setMainFrameURL:document.location.href.substring(0, document.location.href.lastIndexOf('/')) + @"/Frameworks/CPVideoKit/" + [_player iFrameFileName]];
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
    [_player embedInDOM:[self DOMWindow]]; 
}

// functions for the api calls
- (void)loadVideo:(CPString)id
{
    [self loadVideo:id startSeconds:0];
}

- (void)loadVideo:(CPString)id startSeconds:(int)startSeconds
{
    [_player loadVideo:id startSeconds:startSeconds];
}

- (void)cueVideo:(CPString)id
{
    [self cueVideo:id startSeconds:0];
}

- (void)cueVideo:(CPString)id startSeconds:(int)startSeconds 
{
    [_player cueVideo:id startSeconds:startSeconds];
}


- (IBAction)play:(id)sender
{
    [_player play];
}

- (IBAction)pause:(id)sender 
{
    [_player pause];
}

- (IBAction)stop:(id)sender
{
    [_player stop];
}


- (void)setMuted:(BOOL)muted 
{
    [_player setMuted:muted];
}

- (BOOL)isMuted
{
    return [_player isMuted];
}

- (void)setVolume:(int)newVolume
{
    [_player setVolume:newVolume];
}

- (int) volume
{
    return [_player volume];
}

- (void)clearVideo
{
    [_player clearVideo];
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
    [_player seekTo:seconds];
}

- (void)setFrameSize:(CGSize)aSize
{
    [super setFrameSize:aSize];
    var bounds = [self bounds];

}

- (void)videoPlayerIsReady:(id)videoPlayer
{
    if (delegate && [delegate respondsToSelector:@selector(videoViewIsReady:)]) 
    {
        [delegate videoViewIsReady:self];
    }
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
    return _player.ready;
}


@end

