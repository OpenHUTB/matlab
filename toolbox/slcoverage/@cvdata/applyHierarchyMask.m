function applyHierarchyMask(this,targetCvIds,mask)



    if nargin<2
        targetCvIds=[];
    end


    if mask.mode
        return;
    end
    if isempty(mask.scope)
        return;
    end
    if isempty(targetCvIds)
        targetCvIds=findMaskCvIds(this,mask);
    end

    if isempty(targetCvIds)
        return;
    end
    setFilterData(this,targetCvIds);
end

function setFilterData(cvd,targetCvIds)

    rules=cell(1,numel(targetCvIds));
    for idx=1:numel(targetCvIds)
        cb=cv('get',targetCvIds(idx),'.handle');
        obj=get_param(cb,'object');
        if isa(obj,'Simulink.SubSystem')
            sel=slcoverage.BlockSelector(slcoverage.BlockSelectorType.SubsystemAllContent,cb);
            rules{idx}=sel.ConstructorCode;
        elseif isa(obj,'Simulink.Block')
            sel=slcoverage.BlockSelector(slcoverage.BlockSelectorType.BlockInstance,cb);
            rules{idx}=sel.ConstructorCode;
        end
    end
    rules(cellfun(@isempty,rules))=[];
    if~isempty(rules)
        filterData.id=char(matlab.lang.internal.uuid);
        filterData.type='mask';
        filterData.rules=rules;
        filterData.concatOp=1;
        cvd.filterData=filterData;

    end
end
