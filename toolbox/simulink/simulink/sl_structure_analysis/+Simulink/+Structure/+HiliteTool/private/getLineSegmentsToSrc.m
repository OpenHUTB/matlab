

function segs=getLineSegmentsToSrc(seg)
    assert(isa(seg,'double'));
    if(~isempty(seg)&&seg~=-1)
        segs=[];
        lineParent=get_param(seg,'LineParent');
        if(lineParent~=-1)
            segs=[segs,getLineSegmentsToSrc(lineParent)];
        end
        segs=[segs,seg];
    else
        segs=[];
    end

end