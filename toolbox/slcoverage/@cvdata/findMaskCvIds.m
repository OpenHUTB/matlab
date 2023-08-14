function cvIds=findMaskCvIds(this,mask)



    cvIds=[];
    if isempty(mask.scope)
        return;
    end
    cvIds=this.findCvIdsInScope(mask.scope,~mask.invert);
end

