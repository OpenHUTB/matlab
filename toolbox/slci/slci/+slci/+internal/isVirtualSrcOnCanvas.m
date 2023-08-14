function out=isVirtualSrcOnCanvas(blkH,port)




    nonVirtualSrc=slci.internal.getNonVirtualSrc(blkH,port);
    actSrcs=slci.internal.getActualSrc(blkH,port);
    assert(size(actSrcs,1)==1);
    out=(nonVirtualSrc~=actSrcs(1,1));
end
