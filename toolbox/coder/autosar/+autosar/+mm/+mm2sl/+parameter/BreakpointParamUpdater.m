classdef BreakpointParamUpdater<autosar.mm.mm2sl.parameter.AbstractParamUpdater




    methods
        function this=BreakpointParamUpdater(slCalPrm,slCalPrmName,m3iData,...
            m3iInitValue,m3iImpType,slConstBuilder,slTypeBuilder)
            this@autosar.mm.mm2sl.parameter.AbstractParamUpdater(slCalPrm,slCalPrmName,...
            m3iData,m3iInitValue,m3iImpType,slConstBuilder,slTypeBuilder);
        end
    end

    methods(Access=protected)
        function isGroundValueAssigned=assignGroundValue(this)

            groundValue=this.getGroundValue();
            if isempty(groundValue)
                isGroundValueAssigned=false;
            else
                this.SlCalPrm.Breakpoints.Value=groundValue;
                isGroundValueAssigned=true;
            end
        end

        function setDefaultDimensions(this)
            this.SlCalPrm.Breakpoints=this.updateObjDimensions(this.SlCalPrm.Breakpoints);
        end

        function updateFieldNames(this)
            this.SlCalPrm.StructTypeInfo.HeaderFileName='Rte_Type.h';

            assert(this.M3iImpType.isvalid(),'Breakpoint implementation type  must be valid');

            if isa(this.M3iImpType,'Simulink.metamodel.types.Structure')
                this.updateSlBreakpointObjFieldNamesFromM3iImpType();
            end

        end

        function updateValues(this,slValue)
            this.SlCalPrm.Breakpoints.Value=slValue;
        end

        function updateDimensions(~)


        end

        function updateDataType(this,typeStr)
            this.SlCalPrm.Breakpoints.DataType=typeStr;
        end

        function updateMinMaxValues(this,minVal,maxVal)
            this.SlCalPrm.Breakpoints.Min=minVal;
            this.SlCalPrm.Breakpoints.Max=maxVal;
        end

        function updateDescription(this,slDesc)
            this.SlCalPrm.Breakpoints.Description=slDesc;
        end
    end

    methods(Access=private)
        function updateSlBreakpointObjFieldNamesFromM3iImpType(this)
            this.SlCalPrm.StructTypeInfo.Name=this.M3iImpType.Name;
            for elementIndex=1:this.M3iImpType.Elements.size()
                m3iStructElement=this.M3iImpType.Elements.at(elementIndex);
                if isa(m3iStructElement.Type,'Simulink.metamodel.types.PrimitiveType')
                    this.SlCalPrm.Breakpoints.TunableSizeName=m3iStructElement.Name;
                    this.SlCalPrm.SupportTunableSize=true;
                else
                    this.SlCalPrm.Breakpoints.FieldName=m3iStructElement.Name;
                end
            end
        end
    end
end


