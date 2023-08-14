function result=promote(this,req)






    if~isa(req,'slreq.data.Requirement')||~isvalid(req)
        error('Invalid input: expected slreq.data.Requirement');
    end

    parent=req.parent;
    if isempty(parent)
        error(message('Slvnv:slreq:ErrorForPromote',req.id));
    else
        higherParent=parent.parent;
        if parent.isJustification&&isempty(higherParent)


            error(message('Slvnv:slreq:ErrorForPromoteJustification',req.id))
        end
        req.parent=higherParent;
        result=true;
    end
end
