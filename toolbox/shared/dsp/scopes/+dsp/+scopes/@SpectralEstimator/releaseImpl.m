function releaseImpl(obj)





    flush(obj.sSegmentBuffer);
    releaseDDC(obj);
    obj.pIsLockedFlag=false;
end
