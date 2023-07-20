classdef DefaultParamUpdater<autosar.mm.mm2sl.parameter.AbstractParamUpdater




    methods
        function this=DefaultParamUpdater(slCalPrm,slCalPrmName,...
            m3iData,m3iInitValue,m3iImpType,slConstBuilder,slTypeBuilder)
            this@autosar.mm.mm2sl.parameter.AbstractParamUpdater(slCalPrm,slCalPrmName,...
            m3iData,m3iInitValue,m3iImpType,slConstBuilder,slTypeBuilder);
        end
    end

    methods(Access=protected)
        function shouldAssignDefault=assignGroundValue(this)
            shouldAssignDefault=...
            isempty(this.SlCalPrm.Value)||...
            isa(this.M3iData,'Simulink.metamodel.arplatform.interface.ArgumentData');
            if shouldAssignDefault
                if isa(this.M3iData.Type,'Simulink.metamodel.types.Enumeration')&&...
                    isa(this.SlTypeBuilder.SharedWorkSpace,'Simulink.dd.Connection')


                    this.SlTypeBuilder.createAll(this.SlTypeBuilder.SharedWorkSpace);
                end
                this.SlCalPrm.Value=this.getGroundValue();
            end
        end

        function updateValues(this,value)
            this.SlCalPrm.Value=value;
        end

        function updateDimensions(this)
            if(ischar(this.SlCalPrm.Dimensions)||isStringScalar(this.SlCalPrm.Dimensions))||...
                (isfield(this.SlTypeInfo,'dims')&&this.SlTypeInfo.dims.containsSymbols())






                this.updateObjDimensions(this.SlCalPrm);
            end
        end

        function updateDataType(this,typeStr)
            this.SlCalPrm.DataType=typeStr;
        end

        function updateMinMaxValues(this,minVal,maxVal)
            this.SlCalPrm.Min=minVal;
            this.SlCalPrm.Max=maxVal;
        end

        function updateDescription(this,slDesc)
            this.SlCalPrm.Description=slDesc;
        end
    end
end


