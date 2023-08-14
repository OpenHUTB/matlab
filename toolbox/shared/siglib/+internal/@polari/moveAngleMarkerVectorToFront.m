function moveAngleMarkerVectorToFront(p,mThis)







    Nthis=numel(mThis);
    if Nthis==0
        return
    end


    mOther=[p.hPeakAngleMarkers;p.hCursorAngleMarkers];
    Nother=numel(mOther);
    Nall=Nother+Nthis;


    zi=0.3;
    del=(0.4-zi)/Nall;


    if Nother>0
        [~,zOrder]=sort([mOther.Z]);
        for i=1:Nother
            mOther(zOrder(i)).Z=zi;
            zi=zi+del;
        end
    end


    for i=1:Nthis
        mThis(i).Z=zi;
        zi=zi+del;
    end
