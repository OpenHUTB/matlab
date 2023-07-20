classdef(Abstract,Hidden)BaseElement<matlab.mixin.SetGet&matlab.mixin.Heterogeneous





    properties(Dependent,SetAccess=private)
        Owner;
    end

    properties(Access=protected,Hidden)
ZCImpl
        DictImpl sl.interface.dict.InterfaceDictionary
    end

    methods
        function b=isequal(this,other)

            b=isequal(this.ZCImpl.UUID,other.ZCImpl.UUID);
        end

        function delete(this)
            this.ZCImpl=mf.zero.ModelElement.empty;
        end

        function destroy(this)
            if~isempty(this.ZCImpl)&&this.ZCImpl.isvalid
                this.ZCImpl.destroy();
            end
            delete(this);
        end

        function owner=get.Owner(this)
            owner=this.getOwner();
        end
    end

    methods(Access=protected)
        function owner=getOwner(this)

            owner=this.getDictionary();
        end
    end

    methods(Hidden)
        function this=BaseElement(zcImpl,dictImpl)
            this.ZCImpl=zcImpl;
            this.DictImpl=dictImpl;
        end

        function zcImpl=getZCImpl(this)
            zcImpl=this.ZCImpl;
        end

        function dictImpl=getDictImpl(this)
            dictImpl=this.DictImpl;
        end

        function wrapper=getZCWrapper(this)
            wrapper=this.ZCImpl.cachedWrapper;
        end

        function tf=getIsStereotypableElement(this)%#ok<MANU>

            tf=false;
        end

        function valid=isValid(this)


            zcImpl=this.getZCImpl();
            valid=zcImpl.isvalid();
        end

        function dict=getDictionary(this)
            dict=Simulink.interface.dictionary.open(this.DictImpl.getDictionaryFilePath);
        end
        function sourceName=getSourceName(this)
            sourceName=Simulink.interface.dictionary.BaseElement.getSourceNameImpl(this.ZCImpl);
        end
    end

    methods(Hidden,Static)
        function sourceName=getSourceNameImpl(zcImpl)
            zcDictImpl=systemcomposer.architecture.model.interface.InterfaceCatalog.getInterfaceCatalog(...
            mf.zero.getModel(zcImpl));
            sourceName=zcDictImpl.getStorageSource();
        end
    end
end


