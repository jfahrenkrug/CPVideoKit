@import <Foundation/CPObject.j>

@implementation CPVimeoVideoPlayer : CPObject
{
    BOOL _ready @accessors(property=ready);
    JSObject _jsPlayer @accessors(property=jsPlayer);
    int _percentageLoaded @accessors(property=percentageLoaded);
    int _bytesLoaded @accessors(property=bytesLoaded);
    int _bytesTotal @accessors(property=bytesTotal);
    int _duration @accessors(property=duration);
    int _currentTime @accessors(property=currentTime);
    int _volume;
    id delegate @accessors;
    JSObject _domWin;
}

- (CPString)iFrameFileName
{
    return @"iframe-vimeo.html";
}

- (id)init
{
    if (self = [super init])
    {
        _volume = 100;
        _muted = NO;
    }
    return self;
}

- (void)updateData
{
    [self setDuration:_jsPlayer.api_getDuration()];
    [self setCurrentTime:_jsPlayer.api_getCurrentTime()];
    [self setBytesLoaded:0];
    [self setBytesTotal:0];
    [self setPercentageLoaded:0];
}

- (void)embedInDOM:(JSObject)domWin
{
    [self embedInDOM:domWin withVideoID:NULL];
}

- (void)embedInDOM:(JSObject)domWin withVideoID:(int)videoID
{
    _domWin = domWin;

    var playerReadyCallback = function() 
    {
        _ready = YES;
        if (delegate && [delegate respondsToSelector:@selector(videoPlayerIsReady:)]) 
        {
            [delegate videoPlayerIsReady:self];
        }
    }

    var updateData = function() 
    {
        console.log('update data vimeo');
        [self updateData];
    };
    

    domWin.onVimeoPlayerReady = function(playerId) {
        _jsPlayer = domWin.document.getElementById(playerId);
        domWin.setInterval(updateData, 250);
        //updateytplayerInfo();
        //ytplayer.addEventListener("onStateChange", "onytplayerStateChange");
        //ytplayer.addEventListener("onError", "onPlayerError");
        playerReadyCallback();
    };
      

    var flashvars = {
        clip_id: videoID,
        show_portrait: 1,
        show_byline: 1,
        show_title: 1,
        js_api: 1, // required in order to use the Javascript API
        js_onLoad: 'onVimeoPlayerReady', // moogaloop will call this JS function when it's done loading (optional)
        js_swf_id: 'CPVideoViewDiv' // this will be passed into all event methods so you can keep track of multiple moogaloops (optional)
    };
    var params = {
        allowscriptaccess: 'always',
        allowfullscreen: 'true'
    };


    // For more SWFObject documentation visit: http://code.google.com/p/swfobject/wiki/documentation
    domWin.swfobject.embedSWF("http://vimeo.com/moogaloop.swf", "CPVideoViewDiv", "100%", "100%", "9.0.0","expressInstall.swf", flashvars, params, {});
}

// functions for the api calls
- (void)loadVideo:(CPString)id
{
    [self loadVideo:id startSeconds:0];
}

- (void)loadVideo:(CPString)id startSeconds:(int)startSeconds
{
    //this is really ugly atm, but the API doesn't allow me to load a different video...
    [self embedInDOM:_domWin withVideoID:id];
}

- (void)cueVideo:(CPString)id
{
    [self cueVideo:id startSeconds:0];
}

- (void)cueVideo:(CPString)id startSeconds:(int)startSeconds 
{
    //noop
}


- (void)play
{
  if (_ready) 
  {
    _jsPlayer.api_play();
  }
}

- (void)pause 
{
    if (_ready) 
    {
        _jsPlayer.api_pause();
    }
}

- (void)stop
{
    [self pause];
}


- (void)setMuted:(BOOL)muted 
{
    if (_ready) 
    {
        if (muted)
        {
            _jsPlayer.api_setVolume(0);
            _muted = YES;
        } 
        else
        {
            _jsPlayer.api_setVolume(_volume);
            _muted = NO;
        }
    }
}

- (BOOL)isMuted
{
    if (_ready && _muted) 
    {
        return YES;
    }
    
    return NO;
}

- (void)setVolume:(int)newVolume
 {
     if (_ready) 
     {
        _volume = newVolume;
        if (!_muted)
        {
            _jsPlayer.api_setVolume(newVolume);
        }
     }
}

- (int) volume
{
    if (_ready) 
    {
        return _volume;
    }
    
    return 0;
}

- (void)clearVideo
{
    if (_ready) 
    {
        _jsPlayer.api_unload();
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
    if (_ready) 
    {
        _jsPlayer.api_seekTo(seconds);
    }
}

@end
