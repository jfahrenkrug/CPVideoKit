
@import <Foundation/CPObject.j>

@implementation CPYouTubeVideoPlayer : CPObject
{
    BOOL _ready @accessors(property=ready);
    JSObject _jsPlayer @accessors(property=jsPlayer);
    int _percentageLoaded @accessors(property=percentageLoaded);
    int _bytesLoaded @accessors(property=bytesLoaded);
    int _bytesTotal @accessors(property=bytesTotal);
    int _duration @accessors(property=duration);
    int _currentTime @accessors(property=currentTime);
    id delegate @accessors;
}

- (CPString)iFrameFileName
{
    return @"iframe-youtube.html";
}

- (id)init
{
    if (self = [super init])
    {
        
    }
    return self;
}

- (void)updateData
{
    [self setDuration:_jsPlayer.getDuration()];
    [self setCurrentTime:_jsPlayer.getCurrentTime()];
    [self setBytesLoaded:_jsPlayer.getVideoBytesLoaded()];
    [self setBytesTotal:_jsPlayer.getVideoBytesTotal()];
    [self setPercentageLoaded:(_bytesLoaded/(_bytesTotal/100.0))];
}

- (void)embedInDOM:(JSObject)domWin
{
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
        console.log('update data');
        [self updateData];
    };
    

    domWin.onYouTubePlayerReady = function(playerId) {
        _jsPlayer = domWin.document.getElementById("CPVideoViewEmbed");
        domWin.setInterval(updateData, 250);
        //updateytplayerInfo();
        //ytplayer.addEventListener("onStateChange", "onytplayerStateChange");
        //ytplayer.addEventListener("onError", "onPlayerError");
        playerReadyCallback();
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
    console.log("yt loadVideo");
    [self loadVideo:id startSeconds:0];
}

- (void)loadVideo:(CPString)id startSeconds:(int)startSeconds
{
    if (_ready) 
    {
        _jsPlayer.loadVideoById(id, parseInt(startSeconds));
    }
}

- (void)cueVideo:(CPString)id
{
    [self cueVideo:id startSeconds:0];
}

- (void)cueVideo:(CPString)id startSeconds:(int)startSeconds 
{
    if (_ready) 
    {
        _jsPlayer.cueVideoById(id, startSeconds);
    }
}


- (void)play
{
  if (_ready) 
  {
    _jsPlayer.playVideo();
  }
}

- (void)pause 
{
    if (_ready) 
    {
        _jsPlayer.pauseVideo();
    }
}

- (void)stop
{
    if (_ready) 
    {
        _jsPlayer.stopVideo();
    }
}


- (void)setMuted:(BOOL)muted 
{
    if (_ready) 
    {
        if (muted)
        {
            _jsPlayer.mute();
        } 
        else
        {
            _jsPlayer.unMute();
        }
    }
}

- (BOOL)isMuted
{
    if (_ready && _jsPlayer.isMuted()) 
    {
        return YES;
    }
    
    return NO;
}

- (void)setVolume:(int)newVolume
 {
     if (_ready) 
     {
         _jsPlayer.setVolume(newVolume);
     }
}

- (int) volume
{
    if (_ready) 
    {
        return _jsPlayer.getVolume();
    }
    
    return 0;
}

- (void)clearVideo
{
    if (_ready) 
    {
        _jsPlayer.clearVideo();
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
        _jsPlayer.seekTo(seconds, true);
    }
}

@end
