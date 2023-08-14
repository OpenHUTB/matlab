classdef Allocation<systemcomposer.base.StereotypableElement





    properties(Dependent=true,SetAccess=private)
Source
Target
Scenario
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

        function source=get.Source(obj)
            srcImpl=obj.Impl.p_Source;
            source=[];
            if~isempty(srcImpl)
                source=systemcomposer.internal.getWrapperForImpl(srcImpl.getElement);
            end
        end

        function target=get.Target(obj)
            tgtImpl=obj.Impl.p_Target;
            target=[];
            if~isempty(tgtImpl)
                target=systemcomposer.internal.getWrapperForImpl(tgtImpl.getElement);
            end
        end

        function scenario=get.Scenario(obj)
            scenario=systemcomposer.allocation.internal.getWrapperForImpl(obj.Impl.p_Scenario);
        end

        function destroy(obj)



            txn=obj.MFModel.beginTransaction;
            obj.Impl.destroy;
            txn.commit;
            delete(obj);
        end
    end

    methods(Hidden)
        function applyStereotype(this,stereotypeName)
            if(slfeature('AllocationStereotypes')<1)
                error(DAStudio.message('SystemArchitecture:Property:NotPrototypable','Allocation'));
            end
            applyStereotype@systemcomposer.base.StereotypableElement(this,stereotypeName);
        end
        function obj=Allocation(implObj)
            assert(isa(implObj,'systemcomposer.allocation.model.Allocation'));
            if isempty(implObj)
                obj=systemcomposer.allocation.Allocation.empty;
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

