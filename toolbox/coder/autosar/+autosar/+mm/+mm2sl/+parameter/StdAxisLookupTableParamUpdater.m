classdef StdAxisLookupTableParamUpdater<autosar.mm.mm2sl.parameter.LookupTableParamUpdater





    methods
        function this=StdAxisLookupTableParamUpdater(slCalPrm,slCalPrmName,m3iData,...
            m3iInitValue,m3iImpType,slConstBuilder,slTypeBuilder)
            this@autosar.mm.mm2sl.parameter.LookupTableParamUpdater(slCalPrm,slCalPrmName,...
            m3iData,m3iInitValue,m3iImpType,slConstBuilder,slTypeBuilder);
        end
    end

    methods(Access=protected)

        function setDefaultDimensions(this)

            setDefaultDimensions@autosar.mm.mm2sl.parameter.LookupTableParamUpdater(this);


            if isfield(this.SlTypeInfo,'dims')
                [outDims,symbolicExprsForAxisDims]=this.SlTypeInfo.dims.dataObjStyle();
            end


            if this.SlTypeInfo.dims.containsSymbols()

                if~isempty(symbolicExprsForAxisDims)
                    for bpIndex=1:numel(symbolicExprsForAxisDims)
                        this.SlCalPrm.Breakpoints(bpIndex).Dimensions=symbolicExprsForAxisDims{bpIndex};
                    end
                else


                    this.SlCalPrm.Breakpoints(1).Dimensions=outDims;
                end
            else

                numberOfBreakpoints=this.M3iData.Type.Axes.size;
                for bpIndex=1:numberOfBreakpoints
                    this.SlCalPrm.Breakpoints(bpIndex).Value=1:outDims(bpIndex);
                end
            end
        end

        function updateFieldNames(this)
            updateFieldNames@autosar.mm.mm2sl.parameter.LookupTableParamUpdater(this);
            this.updateSlLookupTableObjFieldNames();
        end

        function updateValues(this,slStructValue)


            if isa(slStructValue,'struct')


                structFieldNames=fieldnames(slStructValue);
                numberOfAxes=this.M3iData.Type.Axes.size();
                expectedTableDimensions=ones(1,numberOfAxes);
                for axisIndex=1:numberOfAxes
                    breakpointFieldName=this.SlCalPrm.Breakpoints(axisIndex).FieldName;
                    defaultBreakpointFieldName=['Breakpoint',num2str(axisIndex)];
                    if any(strcmp(structFieldNames,breakpointFieldName))
                        slBreakpointValues=slStructValue.(breakpointFieldName);
                    elseif any(strcmp(structFieldNames,defaultBreakpointFieldName))
                        slBreakpointValues=slStructValue.(defaultBreakpointFieldName);
                    else
                        assert(false,sprintf('Unexpected field name from the structure of init values'));
                    end
                    this.SlCalPrm.Breakpoints(axisIndex).Value=slBreakpointValues;
                    breakpointDimension=size(slBreakpointValues,1);
                    expectedTableDimensions(axisIndex)=breakpointDimension;
                end

                tableFieldName=this.SlCalPrm.Table.FieldName;
                if any(strcmp(structFieldNames,tableFieldName))
                    slTableValues=slStructValue.(tableFieldName);
                elseif any(strcmp(structFieldNames,'Table'))
                    slTableValues=slStructValue.Table;
                else
                    assert(false,sprintf('Unexpected field name from the structure of init values'));
                end

                this.SlCalPrm.Table.Value=this.reshapeTableValues(...
                slTableValues,expectedTableDimensions);
            else

                this.SlCalPrm.Table.Value=slStructValue;
            end
        end

        function updateDataType(this,typeStr)

            updateDataType@autosar.mm.mm2sl.parameter.LookupTableParamUpdater(this,typeStr);

            m3iType=this.M3iData.Type;
            axisCount=m3iType.Axes.size();
            for axisIndex=1:axisCount
                index=autosar.mm.util.getLookupTableMemberSwappedIndex(axisCount,axisIndex);
                this.SlCalPrm.Breakpoints(index).DataType=...
                this.SlTypeBuilder.getSLBlockDataTypeStr(m3iType.Axes.at(axisIndex));
            end
        end

        function updateMinMaxValues(this,minVal,maxVal)

            updateMinMaxValues@autosar.mm.mm2sl.parameter.LookupTableParamUpdater(this,minVal,maxVal);

            m3iType=this.M3iData.Type;
            axisCount=m3iType.Axes.size();
            for axisIndex=1:axisCount
                index=autosar.mm.util.getLookupTableMemberSwappedIndex(axisCount,axisIndex);
                [isSupported,minVal,maxVal]=...
                autosar.mm.util.MinMaxHelper.getMinMaxValuesFromM3iType(m3iType.Axes.at(axisIndex),this.SlTypeInfo.slObj);
                if isSupported
                    this.SlCalPrm.Breakpoints(index).Min=minVal;
                    this.SlCalPrm.Breakpoints(index).Max=maxVal;
                end
            end
        end

    end

    methods(Access=private)
        function updateSlLookupTableObjFieldNames(this)
            this.SlCalPrm.StructTypeInfo.Name=this.M3iImpType.Name;
            if~isa(this.M3iImpType,'Simulink.metamodel.types.Structure')

                return;
            end

            tunableSizeNames={};
            fieldNames={};

            for elementIdx=1:this.M3iImpType.Elements.size()
                m3iStructElement=this.M3iImpType.Elements.at(elementIdx);

                if isa(m3iStructElement.Type,'Simulink.metamodel.types.PrimitiveType')
                    tunableSizeNames{end+1}=this.M3iImpType.Elements.at(elementIdx).Name;%#ok<AGROW>
                else
                    fieldNames{end+1}=this.M3iImpType.Elements.at(elementIdx).Name;%#ok<AGROW>
                end
            end

            tableFieldName=fieldNames(end);
            breakpointFieldNames=fieldNames(1:end-1);

            [daVinciBPNames,daVinciTunableSizeNames,daVinciTableName]=...
            autosar.mm.sl2mm.utils.DaVinciLUT.getLookupTableFieldNames(this.M3iImpType);
            if~isempty(daVinciBPNames)
                if numel(daVinciBPNames)~=numel(breakpointFieldNames)||...
                    numel(daVinciTableName)~=numel(tableFieldName)||...
                    numel(daVinciTunableSizeNames)~=numel(tunableSizeNames)
                    DAStudio.warning('autosarstandard:importer:incorrectDaVinciLUTAdminDataFieldNames',...
                    autosar.api.Utils.getQualifiedName(this.M3iImpType));
                    return;
                end

                tableFieldName=daVinciTableName;
                breakpointFieldNames=daVinciBPNames;
                tunableSizeNames=daVinciTunableSizeNames;
            end

            if isempty(tunableSizeNames)
                this.SlCalPrm.SupportTunableSize=false;
            else
                this.SlCalPrm.SupportTunableSize=true;
            end

            numberOfAxes=numel(breakpointFieldNames);
            for axisIndex=1:numberOfAxes
                swappedIndex=autosar.mm.util.getLookupTableMemberSwappedIndex(numberOfAxes,axisIndex);
                if this.SlCalPrm.SupportTunableSize
                    this.SlCalPrm.Breakpoints(swappedIndex).TunableSizeName=tunableSizeNames{axisIndex};
                end
                this.SlCalPrm.Breakpoints(swappedIndex).FieldName=breakpointFieldNames{axisIndex};
            end
            if numel(this.SlCalPrm.Breakpoints)~=numberOfAxes
                DAStudio.error('autosarstandard:importer:InvalidLUTImplementationType',...
                autosar.api.Utils.getQualifiedName(this.M3iImpType),...
                autosar.api.Utils.getQualifiedName(this.M3iData.Type));
            end

            this.SlCalPrm.Table.FieldName=tableFieldName{1};
        end
    end
end


