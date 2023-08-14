function cons=getAutoZoomConstraint(hAx,orig_cons,startPt,endPt,maxPixels)

    if~(is2D(hAx)&&(nargin>3)&&strcmp(orig_cons,'unconstrained')&&~strcmp(hAx.DataAspectRatioMode,'manual'))
        cons=orig_cons;
        return
    end



    tooSkinny=(abs(startPt(1)-endPt(1))<maxPixels);
    tooShort=(abs(startPt(2)-endPt(2))<maxPixels);
    if tooSkinny&&tooShort
        cons='unconstrained';
    elseif tooSkinny
        cons='y';
    elseif tooShort
        cons='x';
    else
        cons=orig_cons;
    end
