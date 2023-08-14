function wrapperObjs=getWrapperForImpl(implObjs)



    if isempty(implObjs)
        wrapperObjs=hGetWrapperForImpl(implObjs);
        return;
    end
    wrapperObjs=arrayfun(@(i)hGetWrapperForImpl(i),implObjs);

end

function wrapperObj=hGetWrapperForImpl(implObj)

    wrapperObj=[];
    if~isempty(implObj)
        wrapperObj=implObj.cachedWrapper;
    end
    if isempty(wrapperObj)||~isvalid(wrapperObj)
        if isa(implObj,'systemcomposer.allocation.model.AllocationSet')
            wrapperObj=systemcomposer.allocation.AllocationSet(implObj);
        elseif isa(implObj,'systemcomposer.allocation.model.AllocationScenario')
            wrapperObj=systemcomposer.allocation.AllocationScenario(implObj);
        elseif isa(implObj,'systemcomposer.allocation.model.Allocation')
            wrapperObj=systemcomposer.allocation.Allocation(implObj);
        end
    end
end

