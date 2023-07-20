classdef FixAxisLookupTableParamUpdater<autosar.mm.mm2sl.parameter.LookupTableParamUpdater





    methods
        function this=FixAxisLookupTableParamUpdater(slCalPrm,slCalPrmName,m3iData,...
            m3iInitValue,m3iImpType,slConstBuilder,slTypeBuilder)
            this@autosar.mm.mm2sl.parameter.LookupTableParamUpdater(slCalPrm,slCalPrmName,...
            m3iData,m3iInitValue,m3iImpType,slConstBuilder,slTypeBuilder);
        end
    end

    methods(Access=protected)
        function isGroundValueAssigned=assignGroundValue(this)

            groundValue=this.getGroundValue();
            if isempty(groundValue)||...
                ~isempty(this.SlCalPrm.Value)
                isGroundValueAssigned=false;
            else
                isGroundValueAssigned=true;
                this.SlCalPrm.Value=groundValue;
            end
        end

        function setDefaultDimensions(this)

            this.SlCalPrm=this.updateObjDimensions(this.SlCalPrm);
        end

        function updateFieldNames(~)

        end

        function updateValues(this,slValue)
            numberOfAxes=this.M3iData.Type.Axes.size();
            expectedTableDimensions=ones(1,numberOfAxes);
            for axisIndex=1:numberOfAxes
                index=autosar.mm.util.getLookupTableMemberSwappedIndex(numberOfAxes,axisIndex);
                expectedTableDimensions(axisIndex)=this.M3iData.Type.Dimensions.at(index);
            end

            if isa(slValue,'struct')
                structFieldNames=fieldnames(slValue);
                expectedNumberOfTableValues=prod(expectedTableDimensions);
                slTableValues=[];
                for idx=1:numel(structFieldNames)
                    slFieldValue=slValue.(structFieldNames{idx});
                    if numel(slFieldValue)==expectedNumberOfTableValues
                        slTableValues=slFieldValue;
                        break;
                    end
                end
            else
                slTableValues=slValue;
            end
            assert(~isempty(slValue),sprintf(...
            'Table values are not specified correctly for Fix Axis Lookup table: %s',this.SlCalPrmName));

            this.SlCalPrm.Value=this.reshapeTableValues(slTableValues,expectedTableDimensions);
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
