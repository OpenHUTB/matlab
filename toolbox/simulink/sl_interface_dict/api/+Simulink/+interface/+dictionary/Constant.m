classdef(Hidden)Constant<matlab.mixin.SetGet&matlab.mixin.Heterogeneous




    properties(Access=private,Transient)
        InterfaceDictAPI Simulink.interface.Dictionary
ConstantEntryUUID
    end

    properties(Transient)
Name
Value
DataType
Description
    end

    methods
        function this=Constant(interfaceDictAPI,dtEntryUUID)
            this.InterfaceDictAPI=interfaceDictAPI;
            this.ConstantEntryUUID=dtEntryUUID;
        end

        function set.Name(this,name)
            entry=this.InterfaceDictAPI.getDDEntryObject(this.Name);
            entry.Name=name;
        end

        function name=get.Name(this)
            catalogEntry=this.InterfaceDictAPI.DictImpl.DictionaryCatalog.Constants.getByKey(this.ConstantEntryUUID);
            name=catalogEntry.Name;
        end

        function value=get.Value(this)
            value=this.getDDEntryPropValue('Value');
        end

        function set.Value(this,newValue)
            this.setDDEntryPropValue('Value',newValue);
        end

        function value=get.DataType(this)
            value=this.getDDEntryPropValue('DataType');
        end

        function set.DataType(this,newDataType)
            this.setDDEntryPropValue('DataType',newDataType);
        end

        function value=get.Description(this)
            value=this.getDDEntryPropValue('Description');
        end

        function set.Description(this,newDesc)
            this.setDDEntryPropValue('Description',newDesc);
        end

        function destroy(this)
            this.InterfaceDictAPI.removeConstant(this.Name);
            delete(this);
        end
    end

    methods(Access=private)
        function setDDEntryPropValue(this,propName,newPropValue)
            entry=this.InterfaceDictAPI.getDDEntryObject(this.Name);
            dataObj=entry.getValue();
            dataObj.(propName)=newPropValue;
            entry.setValue(dataObj);
        end

        function propValue=getDDEntryPropValue(this,propName)
            dataObj=this.InterfaceDictAPI.getDDEntryObject(this.Name).getValue();
            propValue=dataObj.(propName);
        end
    end
end
