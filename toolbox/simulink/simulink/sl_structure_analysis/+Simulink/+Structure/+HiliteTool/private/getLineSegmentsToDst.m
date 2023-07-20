

function segs=getLineSegmentsToDst(seg)

    assert(isa(seg,'double'));
    segs=[];
    if(seg==-1||isempty(seg))
        return;
    end

    lineChildren=get_param(seg,'LineChildren');
    lineChildren=lineChildren(lineChildren~=-1);

    for j=1:length(lineChildren)
        segs=[segs,getLineSegmentsToDst(lineChildren(j))];
    end
    segs=[segs,seg];

end