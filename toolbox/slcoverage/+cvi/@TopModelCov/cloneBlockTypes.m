function cloneBlockTypes(dstModelcovId,srcModelcovId)




    srcBlockTypeIds=cv('get',srcModelcovId,'.blockTypes');

    if isempty(srcBlockTypeIds)
        return;
    end
    dstBlockTypeIds=zeros(size(srcBlockTypeIds));
    for idx=1:numel(srcBlockTypeIds)
        blktypeStr=cv('get',srcBlockTypeIds(idx),'.type');
        objId=cv('new','typename','.type',blktypeStr);
        dstBlockTypeIds(idx)=objId;
    end

    cv('set',dstModelcovId,'.blockTypes',dstBlockTypeIds);


    rootIds=cv('RootsIn',dstModelcovId);
    for idx1=1:numel(rootIds)
        topSlsfId=cv('get',rootIds(idx1),'.topSlsf');
        descendantCvIds=[topSlsfId,cv('DecendentsOf',topSlsfId)];
        for idx2=1:numel(descendantCvIds)
            slsfobjId=descendantCvIds(idx2);
            slBlckType=cv('get',slsfobjId,'.slBlckType');
            if slBlckType~=0
                blktypeStr=cv('get',slBlckType,'.type');
                blktypeId=cv('find',dstBlockTypeIds,'.type',blktypeStr);
                cv('set',slsfobjId,'.slBlckType',blktypeId);
            end
        end
    end



