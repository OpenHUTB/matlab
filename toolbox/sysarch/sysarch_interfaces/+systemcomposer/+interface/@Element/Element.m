classdef(Abstract,Hidden)Element<dynamicprops&matlab.mixin.SetGet&matlab.mixin.Heterogeneous




    properties(Access=protected,Hidden)
Impl
MFModel
    end

    properties(Dependent=true,SetAccess=private)
UUID
    end

    properties(Dependent=true)
ExternalUID
    end

    methods
        function b=isequal(this,other)

            b=isequal(this.UUID,other.UUID);
        end

        function delete(this)
            this.Impl=mf.zero.ModelElement.empty;
        end

        function uuid=get.UUID(this)
            uuid=this.getImpl().UUID;
        end

        function ExternalUID=get.ExternalUID(this)
            ExternalUID=this.getImpl.getExternalUID;
        end

        function set.ExternalUID(this,newID)
            t=this.MFModel.beginTransaction;
            this.getImpl.setExternalUID(newID);
            t.commit;
        end

        function setTypeFromString(~,~)


            a=1;
        end
    end


    methods(Hidden)
        function this=Element(impl)
            this.Impl=impl;
            this.MFModel=mf.zero.getModel(this.Impl);
        end

        function impl=getImpl(this)
            impl=this.Impl;
        end

        function mfmodel=getMFModel(this)
            mfmodel=this.MFModel;
        end
    end

    methods(Static,Hidden)
        function elem=getObjFromImpl(impl)


            if(isempty(impl))
                elem=[];
                return;
            end

            if isa(impl,'systemcomposer.architecture.model.interface.SignalInterface')
                elem=systemcomposer.arch.SignalInterface(impl);
            elseif isa(impl,'systemcomposer.architecture.model.interface.PhysicalInterface')
                elem=systemcomposer.arch.PhysicalInterface(impl);
            elseif isa(impl,'systemcomposer.architecture.model.interface.SignalElement')
                elem=systemcomposer.interface.SignalElement(impl);
            elseif isa(impl,'systemcomposer.architecture.model.interface.PhysicalElement')
                elem=systemcomposer.interface.PhysicalElement(impl);
            elseif isa(impl,'systemcomposer.architecture.model.interface.InterfaceCatalog')
                elem=systemcomposer.interface.Dictionary(impl);
            else
                elem=[];
                warning(['Invalid fetch of handle for ',class(impl)]);
            end
        end
    end

    methods(Hidden)
        function wrapperObj=getWrapperForImpl(~,impl,wrapperClassName)
            if nargin>2
                wrapperObj=systemcomposer.internal.getWrapperForImpl(impl,wrapperClassName);
            else
                wrapperObj=systemcomposer.internal.getWrapperForImpl(impl);
            end
        end
    end
end
