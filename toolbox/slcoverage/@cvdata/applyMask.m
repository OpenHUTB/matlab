function newCvd=applyMask(this,mask)



    newCvd=[];
    if isempty(mask.scope)
        return;
    end
    if isfield(mask,'invert')
        mask.invert=mask.invert;
    else
        mask.invert=false;
    end
    if isfield(mask,'mode')
        mask.mode=mask.mode;
    else
        mask.mode=0;
    end

    cvIds=findMaskCvIds(this,mask);
    newCvd=applyDataMask(this,cvIds);
    applyHierarchyMask(newCvd,cvIds,mask);
end
