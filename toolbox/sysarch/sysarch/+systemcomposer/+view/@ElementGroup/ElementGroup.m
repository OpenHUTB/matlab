classdef ElementGroup<matlab.mixin.SetGet



    properties(Access=protected,Hidden)
ElementImpl
MFModel
    end

    properties(Dependent=true,SetAccess=private,Hidden)
Select
GroupBy
ZCIdentifier
    end

    properties(Dependent=true)
Name
    end

    properties(Dependent=true,SetAccess=private)
UUID
Elements
SubGroups
    end

    methods
        function b=isequal(this,other)

            b=isequal(this.getImpl,other.getImpl);
        end

        function b=eq(this,other)

            b=isequal(this.getImpl,other.getImpl);
        end

        function delete(this)
            this.ElementImpl=mf.zero.ModelElement.empty;
        end

        function uuid=get.UUID(this)

            uuid=this.getImpl.UUID;
        end

        function name=get.Name(this)
            name=this.getImpl.p_Name;
        end

        function set.Name(this,newName)
            this.getImpl.setName(newName);
        end

        function select=get.Select(this)


            queryImpl=this.getImpl.p_Query;
            groupByImpl=this.getImpl.p_GroupBy;
            select=[];
            if~isempty(groupByImpl)
                select=systemcomposer.query.Constraint.createFromString(groupByImpl.p_Query);
            elseif~isempty(queryImpl)
                select=systemcomposer.query.Constraint.createFromString(queryImpl.p_Constraint);
            end
        end

        function groupBy=get.GroupBy(this)


            groupByImpl=this.getImpl.p_GroupBy;
            groupBy={};
            if~isempty(groupByImpl)
                groupBy{end+1}=groupByImpl.p_GroupByPropFQN;
                while~isempty(groupByImpl.p_SubGroupBy)
                    groupByImpl=groupByImpl.p_SubGroupBy;
                    groupBy{end+1}=groupByImpl.p_GroupByPropFQN;%#ok<AGROW>
                end
            end
        end

        function id=get.ZCIdentifier(this)
            id=this.ElementImpl.getZCIdentifier;
        end

        function elems=get.Elements(this)
            elemImpls=this.getImpl.getElements;
            elems=[];
            for i=1:numel(elemImpls)
                elems=[elems,systemcomposer.internal.getWrapperForImpl(elemImpls(i))];%#ok<AGROW>
            end
        end

        function subGroups=get.SubGroups(this)
            subGroupImpls=this.getImpl.p_SubGroups.toArray;
            subGroups=systemcomposer.view.ElementGroup.empty(0,numel(subGroupImpls));
            for i=1:numel(subGroupImpls)
                subGroups(i)=systemcomposer.internal.getWrapperForImpl(subGroupImpls(i));
            end
        end

        function subGroup=createSubGroup(this,name)
            if~isempty(this.getImpl.getView.getRoot.p_Query)

                systemcomposer.internal.throwAPIError('CantModifyQueryView');
            end

            txn=mf.zero.getModel(this.getImpl).beginTransaction;
            subGroupImpl=this.getImpl.createSubGroup(name);
            txn.commit;
            subGroup=systemcomposer.internal.getWrapperForImpl(subGroupImpl);
        end

        function deleteSubGroup(this,name)
            subGroup=this.getSubGroup(name);
            if~isempty(subGroup)
                subGroup.destroy;
            end
        end

        addElement(this,elementsToAdd);
        removeElement(this,elementsToRemove);

        function subGroup=getSubGroup(this,name)
            subGroupImpl=this.getImpl.getSubGroup(name);
            subGroup=systemcomposer.internal.getWrapperForImpl(subGroupImpl);
        end

        function destroy(this)
            txn=this.MFModel.beginTransaction;
            if this.getImpl.isRootGroup

                this.getImpl.getView.destroy();
            else
                if~isempty(this.getImpl.getView.getRoot.p_Query)

                    systemcomposer.internal.throwAPIError('CantModifyQueryView');
                end
                this.ElementImpl.destroy();
            end
            txn.commit;
        end
    end

    methods(Hidden)
        function this=ElementGroup(elemImpl)
            if~isa(elemImpl,'systemcomposer.architecture.model.views.ElementGroup')
                error('systemcomposer:API:ViewInvalidInput','Invalid argument');
            end
            this.ElementImpl=elemImpl;
            this.MFModel=mf.zero.getModel(this.ElementImpl);

            elemImpl.cachedWrapper=this;
        end

        function impl=getImpl(this)
            impl=this.ElementImpl;
        end
    end
end

