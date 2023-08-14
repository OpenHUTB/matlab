function initializePositionCache(hObj)



    if hObj.InitPositionCache
        pc.PositionCacheNormalized=[0,0,0,0];
        pc.PositionCachePoints=[0,0,0,0];
        pc.PeerPositionCachePoints=[0,0,0,0];
        pc.PeerPositionCacheNorm=[0,0,0,0];
        pc.PinToPeerCacheNorm=[0,0];
        pc.OrientationCache=hObj.Orientation_I;
        hObj.PositionCache=pc;

        hObj.InitPositionCache=false;
    end

