classdef View<matlab.mixin.SetGet






    properties(Access=protected,Hidden)
ElementImpl
MFModel
    end

    properties(Dependent=true,SetAccess=private,Hidden)
Architecture
ZCIdentifier
    end

    properties(Dependent=true)
Name
    end

    properties(Dependent=true,SetAccess=private)
Root
Model
UUID
Select
GroupBy
    end

    properties(Dependent=true)
Color
Description
IncludeReferenceModels
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

        function name=get.Name(this)
            name=this.getImpl.getName;
        end

        function set.Name(this,newName)
            this.getImpl.setName(newName);
        end

        function root=get.Root(this)
            root=systemcomposer.internal.getWrapperForImpl(this.getImpl.getRoot);
        end

        function select=get.Select(this)
            select=this.Root.Select;
        end

        function groupBy=get.GroupBy(this)
            groupBy=this.Root.GroupBy;
        end

        function tf=get.IncludeReferenceModels(this)
            tf=this.getImpl.p_Scope.hasIncludeReferenceModels();
        end

        function set.IncludeReferenceModels(this,tf)
            this.getImpl.p_Scope.setIncludeReferenceModels(tf);
        end

        function arch=get.Architecture(this)
            arch=systemcomposer.arch.Architecture(this.getImpl.p_ViewArchitecture);
        end

        function id=get.ZCIdentifier(this)
            id=this.ElementImpl.getZCIdentifier;
        end

        function uuid=get.UUID(this)

            uuid=this.getImpl.UUID;
        end

        function model=get.Model(this)
            model=systemcomposer.internal.getWrapperForImpl(this.getImpl.p_Model);
        end

        function color=get.Color(this)
            color=this.getImpl.p_Color;
        end

        function set.Color(this,newColor)
            systemcomposer.view.internal.validateColorString(newColor);
            this.getImpl.p_Color=newColor;
        end

        function desc=get.Description(this)
            desc=this.getImpl.p_Description;
        end

        function set.Description(this,newDesc)
            this.getImpl.p_Description=newDesc;
        end

        function runQuery(this)




            this.getImpl.runQuery;
        end

        function destroy(this)
            txn=this.MFModel.beginTransaction;
            this.ElementImpl.destroy();
            txn.commit;
        end

        modifyQuery(obj,varargin);
        removeQuery(obj,keepContents);
    end

    methods(Hidden)
        function this=View(elemImpl)
            if~isa(elemImpl,'systemcomposer.architecture.model.views.View')
                error('systemcomposer:API:ViewInvalidInput','Invalid argument');
            end

            if isempty(elemImpl)
                this=systemcomposer.view.View.empty;
            else
                this.ElementImpl=elemImpl;
                this.MFModel=mf.zero.getModel(this.ElementImpl);
            end

            elemImpl.cachedWrapper=this;
        end

        function impl=getImpl(this)
            impl=this.ElementImpl;
        end

        function recreateArchitecture(this)
            this.getImpl.forceRegenerateArchitecture();
        end
    end
end

