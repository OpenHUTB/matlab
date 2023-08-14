classdef(Abstract,Hidden)DataType<Simulink.interface.dictionary.NamedElement




    properties(Access=protected,Transient)
        InterfaceDictAPI Simulink.interface.Dictionary
    end

    methods(Hidden,Abstract)
        str=getTypeString(this);
    end

    methods
        function this=DataType(interfaceDictAPI,zcImpl)
            this@Simulink.interface.dictionary.NamedElement(zcImpl,interfaceDictAPI.DictImpl);
            this.InterfaceDictAPI=interfaceDictAPI;
        end

        function delete(this)
            if~isempty(this.ZCImpl)
                delete@Simulink.interface.dictionary.NamedElement(this);
            end
        end

        function destroy(this)
            this.InterfaceDictAPI.removeDataType(this.Name);
            delete(this);
        end
    end

    methods(Access=protected)
        function setName(this,newName)



            entry=this.InterfaceDictAPI.getDDEntryObject(this.Name);
            entry.Name=newName;
        end
    end
end


