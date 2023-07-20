classdef LookupTableParamUpdater<autosar.mm.mm2sl.parameter.AbstractParamUpdater




    methods
        function this=LookupTableParamUpdater(slCalPrm,slCalPrmName,m3iData,...
            m3iInitValue,m3iImpType,slConstBuilder,slTypeBuilder)
            this@autosar.mm.mm2sl.parameter.AbstractParamUpdater(slCalPrm,slCalPrmName,...
            m3iData,m3iInitValue,m3iImpType,slConstBuilder,slTypeBuilder);

            assert(m3iImpType.isvalid(),'Lookup table implementation type must be valid');
            if strcmp(this.SlTypeInfo.category,'COM_AXIS')&&...
                isa(m3iImpType,'Simulink.metamodel.types.Structure')
                DAStudio.error('autosarstandard:importer:InvalidLUTImplementationType',...
                autosar.api.Utils.getQualifiedName(m3iImpType),...
                autosar.api.Utils.getQualifiedName(m3iData.Type));
            end
        end
    end

    methods(Access=protected)
        function isGroundValueAssigned=assignGroundValue(this)

            groundValue=this.getGroundValue();
            if isempty(groundValue)
                isGroundValueAssigned=false;
                return;
            else
                isGroundValueAssigned=true;
            end

            this.SlCalPrm.Table.Value=groundValue;
        end

        function setDefaultDimensions(this)

            this.SlCalPrm.Table=this.updateObjDimensions(this.SlCalPrm.Table);
        end

        function updateFieldNames(this)



            this.SlCalPrm.StructTypeInfo.HeaderFileName='Rte_Type.h';
        end

        function updateValues(this,slValue)
            if~this.M3iInitValue.Type.IsApplication
                if slfeature('AUTOSARLUTRecordValueSpec')
                    slValue=this.reshapeTableValues(slValue,this.SlTypeInfo.dims.dataObjStyle());
                else
                    expectedTableDimensions=this.SlTypeInfo.dims.dataObjStyle();
                    valueDimensions=size(slValue);
                    if~all(eq(expectedTableDimensions,valueDimensions))

                        correctSizeString=this.getMatrixSizeString(expectedTableDimensions);
                        incorrectSizeString=this.getMatrixSizeString(valueDimensions);
                        DAStudio.error('autosarstandard:importer:inconsistentLUTDimensions',...
                        incorrectSizeString,...
                        autosar.api.Utils.getQualifiedName(this.M3iInitValue),...
                        correctSizeString);
                    end
                end
            end


            assert(strcmp(this.SlTypeInfo.category,'COM_AXIS'),...
            'Expect only COM_AXIS lookup table in this method');
            this.SlCalPrm.Table.Value=slValue;
            this.SlCalPrm.BreakpointsSpecification='Reference';
        end

        function updateDimensions(~)


        end

        function updateDataType(this,typeStr)
            this.SlCalPrm.Table.DataType=typeStr;
        end

        function updateMinMaxValues(this,minVal,maxVal)
            this.SlCalPrm.Table.Min=minVal;
            this.SlCalPrm.Table.Max=maxVal;
        end

        function updateDescription(this,slDesc)
            this.SlCalPrm.Table.Description=slDesc;
        end

        function reshapedValue=reshapeTableValues(this,slValues,expectedTableDimensions)

            valueDimensions=size(slValues);
            if numel(expectedTableDimensions)==1
                reshapedValue=slValues;
            elseif isvector(slValues)


                reshapedValue=reshape(slValues,expectedTableDimensions);
            elseif numel(valueDimensions)~=numel(expectedTableDimensions)||...
                any(valueDimensions~=expectedTableDimensions)
                correctSizeString=this.getMatrixSizeString(expectedTableDimensions);
                incorrectSizeString=this.getMatrixSizeString(valueDimensions);
                DAStudio.error('autosarstandard:importer:inconsistentLUTDimensions',...
                incorrectSizeString,...
                autosar.api.Utils.getQualifiedName(this.M3iInitValue),correctSizeString);
            else
                reshapedValue=slValues;
            end
        end
    end

    methods(Access=private,Static)
        function sizeString=getMatrixSizeString(slDims)
            sizeString=num2str(slDims(1));
            for ii=2:numel(slDims)
                sizeString=[sizeString,' x ',num2str(slDims(ii))];%#ok<AGROW>
            end
        end
    end
end



