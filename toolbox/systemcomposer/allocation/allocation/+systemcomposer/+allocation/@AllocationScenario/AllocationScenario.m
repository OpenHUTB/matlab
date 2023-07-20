classdef AllocationScenario<handle






    properties(Dependent=true)
Name
Description
    end

    properties(Dependent=true,SetAccess=private)
AllocationSet





Allocations
    end

    properties(SetAccess=private)
UUID
    end

    properties(Access=protected,Hidden)
Impl
MFModel
    end

    methods
        function b=isequal(this,other)

            b=isequal(this.MFModel,other.MFModel)&&isequal(this.UUID,other.UUID);
        end

        function name=get.Name(obj)
            name=obj.Impl.getName;
        end

        function set.Name(obj,newName)
            txn=obj.MFModel.beginTransaction;
            obj.Impl.setName(newName);
            txn.commit;
        end

        function name=get.Description(obj)
            name=obj.Impl.p_Description;
        end

        function set.Description(obj,desc)
            txn=obj.MFModel.beginTransaction;
            obj.Impl.p_Description=desc;
            txn.commit;
        end

        function allocSet=get.AllocationSet(obj)
            allocSet=systemcomposer.allocation.internal.getWrapperForImpl(...
            obj.Impl.p_AllocSet);
        end

        function allocs=get.Allocations(obj)
            allocs=systemcomposer.allocation.internal.getWrapperForImpl(...
            obj.Impl.p_Allocations.toArray);
        end

        function destroy(obj)



            txn=obj.MFModel.beginTransaction;
            obj.Impl.destroy;
            txn.commit;
            delete(obj);
        end

        function elems=getAllocatedTo(obj,source)



            srcAllocEnd=obj.AllocationSet.getImpl.p_SourceModel.getAllocationEnd(source.UUID);
            elems=[];
            if~isempty(srcAllocEnd)
                targetImpls=obj.Impl.getAllocatedTo(srcAllocEnd);
                for i=1:numel(targetImpls)
                    elems=[elems,systemcomposer.internal.getWrapperForImpl(targetImpls(i).getElement)];%#ok<AGROW>
                end
            end
        end

        function elems=getAllocatedFrom(obj,target)



            tgtAllocEnd=obj.AllocationSet.getImpl.p_TargetModel.getAllocationEnd(target.UUID);
            elems=[];
            if~isempty(tgtAllocEnd)
                srcImpls=obj.Impl.getAllocatedFrom(tgtAllocEnd);
                for i=1:numel(srcImpls)
                    elems=[elems,systemcomposer.internal.getWrapperForImpl(srcImpls(i).getElement)];%#ok<AGROW>
                end
            end
        end

        function alloc=getAllocation(obj,source,target)





            if nargin==2

                srcAllocEnd=obj.AllocationSet.getImpl.p_SourceModel.getAllocationEnd(source.UUID);
                tgtAllocEnd=obj.AllocationSet.getImpl.p_TargetModel.getAllocationEnd(source.UUID);
                if isempty(srcAllocEnd)
                    srcAllocEnd=systemcomposer.allocation.model.AllocationSource.empty;
                end

                if isempty(tgtAllocEnd)
                    tgtAllocEnd=systemcomposer.allocation.model.AllocationTarget.empty;
                end

            else
                srcAllocEnd=obj.AllocationSet.getImpl.p_SourceModel.getAllocationEnd(source.UUID);
                tgtAllocEnd=obj.AllocationSet.getImpl.p_TargetModel.getAllocationEnd(target.UUID);
            end

            allocImpl=obj.Impl.getAllocation(srcAllocEnd,tgtAllocEnd);
            alloc=systemcomposer.allocation.internal.getWrapperForImpl(allocImpl);
        end

        function deallocate(obj,source,target)





            alloc=obj.getAllocation(source,target);
            if~isempty(alloc)
                alloc.destroy;
            end
        end

        allocation=allocate(obj,source,target);
    end

    methods(Hidden)
        function obj=AllocationScenario(implObj)
            assert(isa(implObj,'systemcomposer.allocation.model.AllocationScenario'));
            if isempty(implObj)
                obj=systemcomposer.allocation.AllocationScenario.empty;
                return
            end
            obj.Impl=implObj;
            obj.MFModel=mf.zero.getModel(implObj);
            obj.UUID=implObj.UUID;
            implObj.cachedWrapper=obj;
        end

        function impl=getImpl(obj)
            impl=obj.Impl;
        end
    end
end

