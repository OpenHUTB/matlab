function allocation=allocate(obj,source,target)








    verifyIsAllocatable(source,true);
    verifyIsAllocatable(target,false);

    synchronizeWithModelsIfNeeded(obj);

    srcAllocEnd=obj.AllocationSet.getImpl.p_SourceModel.getAllocationEnd(source.UUID);
    if isempty(srcAllocEnd)
        error('SystemComposer:Allocation:SourceElementNotInModel',...
        message('SystemArchitecture:AllocationAPI:SourceElementNotInModel',obj.AllocationSet.SourceModel.Name).string);
    end

    targetAllocEnd=obj.AllocationSet.getImpl.p_TargetModel.getAllocationEnd(target.UUID);
    if isempty(targetAllocEnd)
        error('SystemComposer:Allocation:TargetElementNotInModel',...
        message('SystemArchitecture:AllocationAPI:TargetElementNotInModel',obj.AllocationSet.TargetModel.Name).string);
    end

    txn=obj.MFModel.beginTransaction;
    allocObj=obj.Impl.allocate(srcAllocEnd,targetAllocEnd);
    txn.commit;

    allocation=systemcomposer.allocation.internal.getWrapperForImpl(allocObj);

end

function verifyIsAllocatable(elem,isSource)

    if isa(elem,'systemcomposer.arch.BaseComponent')||...
        isa(elem,'systemcomposer.arch.BaseConnector')||...
        isa(elem,'systemcomposer.arch.ComponentPort')
        return;
    elseif isa(elem,'systemcomposer.arch.ArchitecturePort')&&isempty(elem.Parent.Parent)

        return;
    elseif isa(elem,'systemcomposer.arch.Architecture')&&isempty(elem.Parent)

        return;
    end

    if(isSource)
        error('SystemComposer:Allocation:SourceElementNotAllocatable',...
        message('SystemArchitecture:AllocationAPI:SourceElementNotAllocatable').string);
    else
        error('SystemComposer:Allocation:TargetElementNotAllocatable',...
        message('SystemArchitecture:AllocationAPI:TargetElementNotAllocatable').string);
    end
end

function synchronizeWithModelsIfNeeded(obj)



    allocSet=obj.AllocationSet;
    if allocSet.NeedsRefresh
        warning('SystemComposer:Allocation:AllocationSetSynchronized',...
        message('SystemArchitecture:AllocationAPI:AllocationSetSynchronized',allocSet.Name).string);
        allocSet.synchronizeChanges();
    end
end
