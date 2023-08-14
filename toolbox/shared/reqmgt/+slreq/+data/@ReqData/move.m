function result=move(this,req,offset)



    if offset==0
        return;
    end
    if~isa(req,'slreq.data.Requirement')||~isvalid(req)
        error('Invalid input: expected slreq.data.Requirement');
    end

    parent=req.parent;
    if isempty(parent)

        parent=req.getReqSet();
    end
    currentIndex=parent.indexOf(req);

    alllength=length(parent.children);

    dstPosition=currentIndex+offset;

    if dstPosition<1||dstPosition>alllength
        result=false;
        return;
    end

    dstDataReq=parent.children(currentIndex+offset);

    if offset>0
        result=this.moveRequirement(req,'after',dstDataReq);
    else
        result=this.moveRequirement(req,'before',dstDataReq);
    end

end

