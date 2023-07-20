



function out=getJustification(obj,sid)
    if~obj.isFiltered(sid)
        obj.fManager.justify(sid,'');
    end
    out=obj.fManager.getFilterSpecification(advisor.filter.FilterType.Block,sid);
end
