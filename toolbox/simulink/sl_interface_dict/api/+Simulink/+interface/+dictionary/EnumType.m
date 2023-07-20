classdef EnumType<Simulink.interface.dictionary.DataType&...
    matlab.mixin.CustomDisplay




    properties(Dependent=true)


DefaultValue
StorageType
Description
    end

    properties(Dependent=true,SetAccess=private)
        Enumerals(0,:)Simulink.interface.dictionary.Enumeral
    end

    methods(Hidden,Access=protected)
        function propgrp=getPropertyGroups(~)

            proplist={'Name','Description','DefaultValue','StorageType','Enumerals','Owner'};
            propgrp=matlab.mixin.util.PropertyGroup(proplist);
        end
    end

    methods(Hidden)
        function this=EnumType(interfaceDictAPI,zcImpl)


            this@Simulink.interface.dictionary.DataType(interfaceDictAPI,zcImpl);
        end
    end

    methods
        function addEnumeral(this,name,value,description)
            this.applyMethodOnDDEntry('appendEnumeral',name,value,description);
        end

        function removeEnumeral(this,enumNum)
            this.applyMethodOnDDEntry('removeEnumeral',enumNum);
        end

        function enumeral=getEnumeral(this,enumeralName)
            enumeral=[];

            enumeralImpl=this.ZCImpl.getEnumDataLiteral(enumeralName);
            if~isempty(enumeralImpl)
                enumeral=this.createEnumeral(enumeralImpl);
            end
            if isempty(enumeral)
                DAStudio.error('interface_dictionary:api:TypeElementDoesNotExist',...
                this.Name,enumeralName);
            end
        end

        function set.DefaultValue(this,newValue)
            if isa(newValue,'Simulink.interface.dictionary.Enumeral')
                newValue=newValue.Name;
            end
            this.setDDEntryPropValue('DefaultValue',newValue);
        end

        function defaultValName=get.DefaultValue(this)
            defaultValName=this.getDDEntryPropValue('DefaultValue');
        end

        function set.StorageType(this,newValue)
            this.setDDEntryPropValue('StorageType',newValue);
        end

        function val=get.StorageType(this)
            val=this.getEnumPropVal('StorageType');


            if isempty(val)
                val=DAStudio.message('RTW:configSet:optActiveStateOutputTargetIntegerType');
            end
        end

        function enumerals=get.Enumerals(this)
            enumeralNames=this.getEnumeralNamesPreserveOrder();
            enumerals=Simulink.interface.dictionary.Enumeral.empty(numel(enumeralNames),0);
            for i=1:numel(enumeralNames)
                enumerals(i)=this.getEnumeral(enumeralNames{i});
            end
        end

        function val=get.Description(this)
            val=this.getEnumPropVal('Description');
        end

        function set.Description(this,newDesc)
            this.setDDEntryPropValue('Description',newDesc);
        end
    end

    methods(Hidden)
        function str=getTypeString(this)
            str=['Enum: ',this.Name];
        end
    end

    methods(Access=private)
        function element=createEnumeral(this,enumeralImpl)
            element=Simulink.interface.dictionary.Enumeral(enumeralImpl,this);
        end

        function applyMethodOnDDEntry(this,methodName,varargin)
            enumName=this.Name;
            ddEntry=this.InterfaceDictAPI.getDDEntryObject(enumName);
            ddEntryValue=ddEntry.getValue();
            ddEntryValue.(methodName)(varargin{:});
            this.InterfaceDictAPI.setDDEntryValue(enumName,ddEntryValue);
        end

        function val=getEnumPropVal(this,propName)
            propName=['p_',propName];
            val=this.ZCImpl.(propName);
        end

        function names=getEnumeralNamesPreserveOrder(this)
            names=this.ZCImpl.getEnumLiteralNames();
        end
    end
end


