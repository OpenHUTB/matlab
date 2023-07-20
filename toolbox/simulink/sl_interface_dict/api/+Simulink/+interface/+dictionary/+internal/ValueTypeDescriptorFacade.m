classdef ValueTypeDescriptorFacade<handle






    properties(Access=private)
        ZCImpl systemcomposer.property.ValueTypeDescriptor
SLOwner
    end

    methods
        function this=ValueTypeDescriptorFacade(zcImpl)
            this.ZCImpl=zcImpl;
            if~this.isOwnedType
                this.SLOwner=this.getSLOwner();
            end
        end

        function name=getName(this)
            name='';
            if~this.isOwnedType
                slType=this.ZCImpl.p_DataType;
                name=Simulink.interface.dictionary.TypeUtils.stripPrefix(slType);
            end
        end

        function setName(this,newName)
            systemcomposer.BusObjectManager.RenameInterfaceElement(...
            this.getSourceName,false,this.ParentName,this.Name,newName);
        end

        function typeStr=getDataType(this)
            typeStr=this.getSLPropertyValue('DataType');
        end

        function setDataType(this,type)
            if isa(type,'Simulink.interface.dictionary.DataType')
                typeStr=type.getTypeString();
            else
                typeStr=type;
            end
            this.setSLPropertyValue('Type',typeStr);
        end

        function val=getDimensions(this)
            val=this.getSLPropertyValue('Dimensions');
        end

        function setDimensions(this,value)
            this.setSLPropertyValue('Dimensions',value);
        end

        function val=getUnit(this)
            if this.isOwnedType
                val=this.ZCImpl.p_Units;
            else
                val=this.getSLPropertyValue('Unit');
            end
        end

        function setUnit(this,value)
            this.setSLPropertyValue('Units',value);
        end

        function val=getComplexity(this)
            val=this.getSLPropertyValue('Complexity');
        end

        function setComplexity(this,value)
            this.setSLPropertyValue('Complexity',value);
        end

        function val=getMinimum(this)
            if this.isOwnedType
                val=this.ZCImpl.p_Minimum;
            else
                val=this.getSLPropertyValue('Min');
            end
        end

        function setMinimum(this,value)
            this.setSLPropertyValue('Minimum',value);
        end

        function val=getMaximum(this)
            if this.isOwnedType
                val=this.ZCImpl.p_Maximum;
            else
                val=this.getSLPropertyValue('Max');
            end
        end

        function setMaximum(this,value)
            this.setSLPropertyValue('Maximum',value);
        end

        function val=getDescription(this)
            val=this.getSLPropertyValue('Description');
        end

        function setDescription(this,value)
            this.setSLPropertyValue('Description',value);
        end
    end

    methods(Access=private)

        function tf=isOwnedType(this)
            slType=this.ZCImpl.p_DataType;
            tf=~contains(slType,':');
        end

        function setSLPropertyValue(this,propName,propVal)
            isModelContext=false;
            sourceName=Simulink.interface.dictionary.BaseElement.getSourceNameImpl(this.ZCImpl);
            element=this.ZCImpl.Container;
            parent=element.Container;
            systemcomposer.BusObjectManager.SetInterfaceElementProperty(sourceName,...
            isModelContext,parent.getName,element.getName,propName,propVal);
        end

        function val=getSLPropertyValue(this,propName)
            if this.isOwnedType
                propName=['p_',propName];
                val=this.ZCImpl.(propName);
            else
                val=this.SLOwner.(propName);
                if~ischar(val)
                    val=mat2str(val);
                end
            end
        end

        function slOwner=getSLOwner(this)
            sourceName=Simulink.interface.dictionary.BaseElement.getSourceNameImpl(this.ZCImpl);
            dictName=[sourceName,'.sldd'];
            element=this.ZCImpl.Container;
            parent=element.Container;
            slOwner=Simulink.interface.dictionary.TypeUtils.getBusElementObj(dictName,...
            parent.getName(),element.getName());
        end
    end
end


