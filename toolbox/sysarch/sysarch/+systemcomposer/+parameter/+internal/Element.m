classdef Element<matlab.mixin.SetGet





    properties(Transient,Hidden,Access=protected)
        Impl;
    end

    properties(Dependent,Hidden,SetAccess=private,GetAccess=protected)
        Model;
        UUID;
    end

    methods
        function mdl=get.Model(this)
            mdl=mf.zero.getModel(this.Impl);
        end

        function uuid=get.UUID(this)
            uuid=this.Impl.UUID;
        end

        function tf=eq(this,other)


            tf=isequal(this.UUID,other.UUID);
        end
    end

    methods(Abstract)
        destroy(this);
    end

    methods(Access=protected)
        function this=Element(impl)


            this.setImpl(impl);
        end

        function setImpl(this,impl)




            if~isempty(this.Impl)&&isvalid(this.Impl)
                this.Impl.releaseCachedWrapper();
            end

            this.Impl=impl;
            impl.cachedWrapper=this;
        end
    end

    methods(Hidden)
        function impl=getImpl(this)


            impl=this.Impl;
        end
    end
end
