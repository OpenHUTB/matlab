function[fromTop,fromBottom,fromLeft,fromRight]=findPixelDiffs(cdata,theColor)





    [fromTop,fromBottom]=findTopBottomEdges(cdata,theColor);
    [fromLeft,fromRight]=findLeftRightEdges(cdata,theColor);
end

function[fromLeft,fromRight]=findLeftRightEdges(cdata,theColor)
    fromLeft=0;
    fromRight=0;
    sz=size(cdata);
    cols=sz(2);
    checkColor=repmat(theColor,1,cols);

    vals=find(sum(all(cdata(:,:,:)==checkColor(1,:,:)),3)~=3);
    if~isempty(vals)
        fromLeft=vals(1);
        fromRight=vals(end);
    end
end

function[fromTop,fromBottom]=findTopBottomEdges(cdata,theColor)
    fromTop=0;
    fromBottom=0;
    sz=size(cdata);
    rows=sz(1);
    checkColor=repmat(theColor,rows,1);

    vals=find(sum(all(cdata(:,:,:)==checkColor(1,:,:),2),3)~=3);
    if~isempty(vals)
        fromTop=vals(1);
        fromBottom=vals(end);
    end
end
