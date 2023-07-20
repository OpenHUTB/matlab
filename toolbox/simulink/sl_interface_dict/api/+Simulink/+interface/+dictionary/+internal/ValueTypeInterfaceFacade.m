classdef ValueTypeInterfaceFacade<handle






    properties(Access=private)
        ZCImpl systemcomposer.architecture.model.interface.ValueTypeInterface
    end

    methods
        function this=ValueTypeInterfaceFacade(zcImpl)
            this.ZCImpl=zcImpl;
        end

        function value=getName(this)
            value=this.ZCImpl.cachedWrapper.Name;
        end

        function setName(this,value)
            this.ZCImpl.cachedWrapper.setName(value);
        end

        function typeStr=getDataType(this)
            typeStr=this.ZCImpl.cachedWrapper.DataType;
        end

        function setDataType(this,type)
            if isa(type,'Simulink.interface.dictionary.DataType')
                typeStr=type.getTypeString();
            else
                typeStr=type;
            end
            this.ZCImpl.cachedWrapper.setTypeFromString(typeStr);
        end

        function val=getDimensions(this)
            val=this.ZCImpl.cachedWrapper.Dimensions;
        end

        function setDimensions(this,value)
            this.ZCImpl.cachedWrapper.setDimensions(value);
        end

        function val=getUnit(this)
            val=this.ZCImpl.cachedWrapper.Units;
        end

        function setUnit(this,value)
            this.ZCImpl.cachedWrapper.setUnits(value);
        end

        function val=getComplexity(this)
            val=this.ZCImpl.cachedWrapper.Complexity;
        end

        function setComplexity(this,value)
            this.ZCImpl.cachedWrapper.setComplexity(value);
        end

        function val=getMinimum(this)
            val=this.ZCImpl.cachedWrapper.Minimum;
        end

        function setMinimum(this,value)
            this.ZCImpl.cachedWrapper.setMinimum(value);
        end

        function val=getMaximum(this)
            val=this.ZCImpl.cachedWrapper.Maximum;
        end

        function setMaximum(this,value)
            this.ZCImpl.cachedWrapper.setMaximum(value);
        end

        function val=getDescription(this)
            val=this.ZCImpl.cachedWrapper.Description;
        end

        function setDescription(this,value)
            this.ZCImpl.cachedWrapper.setDescription(value);
        end
    end
end


