classdef(Abstract,Hidden)BaseElement<dynamicprops&matlab.mixin.SetGet&matlab.mixin.Heterogeneous




    properties(Access=protected,Hidden)
ElementImpl
MFModel
    end

    properties(Hidden)
        Visited=false;
        Processed=false;
    end

    properties(Dependent=true,SetAccess=private,Abstract)
Model
    end

    properties(Dependent=true,SetAccess=private)
UUID
    end

    properties(Dependent=true)
ExternalUID
    end

    methods
        function b=isequal(this,other)

            b=isequal(this.MFModel,other.MFModel)&&isequal(this.UUID,other.UUID);
        end

        function delete(this)
            this.ElementImpl=mf.zero.ModelElement.empty;
        end

        function uuid=get.UUID(this)

            uuid=this.getImpl.UUID;
        end

        function ExternalUID=get.ExternalUID(this)
            ExternalUID=this.getImpl.getExternalUID;
        end

        function set.ExternalUID(this,newID)
            t=this.MFModel.beginTransaction;
            this.getImpl.setExternalUID(newID);
            t.commit;
        end
    end

    methods(Hidden)
        function this=BaseElement(elemImpl)
            this.ElementImpl=elemImpl;
            this.MFModel=mf.zero.getModel(this.ElementImpl);
        end

        function impl=getImpl(this)
            impl=this.ElementImpl;
        end
    end

    methods(Static,Sealed,Access=protected)
        function defaultObject=getDefaultScalarElement
            defaultObject=systemcomposer.base.BaseElement.empty;
        end
    end

    methods(Abstract)
        destroy(this)
    end
end

