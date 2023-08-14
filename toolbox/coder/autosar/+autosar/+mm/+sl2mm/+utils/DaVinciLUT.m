classdef DaVinciLUT<handle




    properties(Access=private,Constant)
        ExternalToolName='DaVinciLUTAdminData';
        MajorityExternalToolName='DaVinciLUTAdminDataMajority';
        AxisNames={'X','Y','Z','Z1','Z2'};
        AxisPrefix='AXIS_PTS_';
        AxisCountPrefix='NO_AXIS_PTS_';
        TableLabel='FNC_VALUES';
    end

    methods(Static)
        function addExternalToolInfoToM3iStructImpType(codeDescObj,m3iStructImpType,majority)
            autosar.mm.sl2mm.utils.DaVinciLUT.assertM3iStructType(m3iStructImpType);
            assert(strcmp(majority,'Row-major')||strcmp(majority,'Column-major'),...
            'Expect majority to be either Row or Column Major');

            if isa(codeDescObj,'coder.descriptor.BreakpointDataInterface')
                autosar.mm.sl2mm.utils.DaVinciLUT.addBreakpointExternalToolInfo(...
                codeDescObj,m3iStructImpType)
            elseif isa(codeDescObj,'coder.descriptor.LookupTableDataInterface')
                autosar.mm.sl2mm.utils.DaVinciLUT.addLookupTableExternalToolInfo(...
                codeDescObj,m3iStructImpType,majority);
            else
                assert(false,...
                'Expect Lookup table or breakpoint code descriptor object');
            end
        end

        function removeExternalToolInfoFromM3iStructImpType(m3iStructImpType)
            autosar.mm.sl2mm.utils.DaVinciLUT.assertM3iStructType(m3iStructImpType);

            m3iStructElementSeq=m3iStructImpType.Elements;
            externalToolName=autosar.mm.sl2mm.utils.DaVinciLUT.ExternalToolName;
            majorityExternalToolName=...
            autosar.mm.sl2mm.utils.DaVinciLUT.MajorityExternalToolName;
            for i=1:m3iStructElementSeq.size()
                m3iElement=m3iStructElementSeq.at(i);
                m3iElement.removeExternalToolInfo(...
                M3I.ExternalToolInfo(externalToolName,''));
                m3iElement.removeExternalToolInfo(...
                M3I.ExternalToolInfo(majorityExternalToolName,''));
            end
        end

        function[breakpointFieldNames,tunableSizeNames,tableFieldName]=getLookupTableFieldNames(m3iStructImpType)


            autosar.mm.sl2mm.utils.DaVinciLUT.assertM3iStructType(m3iStructImpType);

            tunableSizeNames={};
            breakpointFieldNames={};
            tableFieldName={};

            externalToolName=autosar.mm.sl2mm.utils.DaVinciLUT.ExternalToolName;

            for elementIdx=1:m3iStructImpType.Elements.size()
                m3iStructElement=m3iStructImpType.Elements.at(elementIdx);
                externalToolID=autosar.mm.sl2mm.utils.DaVinciLUT.getExternalToolID(m3iStructElement,externalToolName);
                if isempty(externalToolID)
                    break;
                end

                if contains(externalToolID,autosar.mm.sl2mm.utils.DaVinciLUT.AxisCountPrefix)
                    axisName=erase(externalToolID,autosar.mm.sl2mm.utils.DaVinciLUT.AxisCountPrefix);
                    axisIndex=find(strcmp([autosar.mm.sl2mm.utils.DaVinciLUT.AxisNames],axisName));
                    if~isempty(axisIndex)
                        tunableSizeNames{axisIndex}=m3iStructImpType.Elements.at(elementIdx).Name;%#ok<AGROW>
                    end
                elseif contains(externalToolID,autosar.mm.sl2mm.utils.DaVinciLUT.AxisPrefix)
                    axisName=erase(externalToolID,autosar.mm.sl2mm.utils.DaVinciLUT.AxisPrefix);
                    axisIndex=find(strcmp([autosar.mm.sl2mm.utils.DaVinciLUT.AxisNames],axisName));
                    if~isempty(axisIndex)
                        breakpointFieldNames{axisIndex}=m3iStructImpType.Elements.at(elementIdx).Name;%#ok<AGROW>
                    end
                elseif strcmp(externalToolID,autosar.mm.sl2mm.utils.DaVinciLUT.TableLabel)
                    tableFieldName={m3iStructElement.Name};
                end
            end

            tunableSizeNames=tunableSizeNames(~cellfun('isempty',tunableSizeNames));
            breakpointFieldNames=breakpointFieldNames(~cellfun('isempty',breakpointFieldNames));
        end

        function isRowMajorLUT=isRowMajorLookupTable(m3iStructImpType)



            autosar.mm.sl2mm.utils.DaVinciLUT.assertM3iStructType(m3iStructImpType);

            isRowMajorLUT=false;
            for elementIdx=1:m3iStructImpType.Elements.size()
                m3iStructElement=m3iStructImpType.Elements.at(elementIdx);
                externalToolName=autosar.mm.sl2mm.utils.DaVinciLUT.MajorityExternalToolName;
                externalToolID=autosar.mm.sl2mm.utils.DaVinciLUT.getExternalToolID(m3iStructElement,externalToolName);

                if contains(externalToolID,'ROW_DIR','IgnoreCase',true)
                    isRowMajorLUT=true;
                    break;
                end
            end
        end
    end

    methods(Static,Access=private)
        function addBreakpointExternalToolInfo(bpCodeDescObj,m3iStructImpType)
            m3iStructElementSeq=m3iStructImpType.Elements;
            m3iSeqIterator=m3iStructElementSeq.begin();



            axisName=autosar.mm.sl2mm.utils.DaVinciLUT.AxisNames{1};
            axisLabel=strcat(autosar.mm.sl2mm.utils.DaVinciLUT.AxisPrefix,axisName);

            if bpCodeDescObj.SupportTunableSize

                axisCountLabel=strcat(autosar.mm.sl2mm.utils.DaVinciLUT.AxisCountPrefix,...
                axisName);
                autosar.mm.sl2mm.utils.DaVinciLUT.setLUTExternalInfoToM3iElement(...
                axisCountLabel,m3iSeqIterator.item());
                m3iSeqIterator.getNext();
            end

            autosar.mm.sl2mm.utils.DaVinciLUT.setLUTExternalInfoToM3iElement(...
            axisLabel,m3iSeqIterator.item());
        end

        function addLookupTableExternalToolInfo(lutCodeDescObj,m3iStructImpType,majority)
            import autosar.mm.sl2mm.LookupTableBuilder;
            if LookupTableBuilder.hasFixAxisLookupTableDataInterface(lutCodeDescObj)


                return;
            end

            m3iStructElementSeq=m3iStructImpType.Elements;

            axisNames=autosar.mm.sl2mm.utils.DaVinciLUT.AxisNames;
            axisCountPrefix=autosar.mm.sl2mm.utils.DaVinciLUT.AxisCountPrefix;

            dimensions=lutCodeDescObj.Breakpoints.Size();

            if lutCodeDescObj.SupportTunableSize
                for i=1:dimensions
                    toolIDString=strcat(axisCountPrefix,axisNames{i});
                    autosar.mm.sl2mm.utils.DaVinciLUT.setLUTExternalInfoToM3iElement(...
                    toolIDString,m3iStructElementSeq.at(i));
                end
            end


            tableValueIndex=LookupTableBuilder.getTableValuesStructElementIndex(lutCodeDescObj);
            autosar.mm.sl2mm.utils.DaVinciLUT.setLUTExternalInfoToM3iElement(...
            autosar.mm.sl2mm.utils.DaVinciLUT.TableLabel,m3iStructElementSeq.at(tableValueIndex));


            majorityLabel=LookupTableBuilder.getModelMajorityLabel(majority,dimensions);
            autosar.mm.sl2mm.utils.DaVinciLUT.setLUTMajorityExternalInfo(...
            majorityLabel,m3iStructElementSeq.at(tableValueIndex));

            axisPrefix=autosar.mm.sl2mm.utils.DaVinciLUT.AxisPrefix;

            for i=1:dimensions
                toolIDString=strcat(axisPrefix,axisNames{i});
                bpIndex=LookupTableBuilder.getBreakpointStructElementIndex(lutCodeDescObj,i);
                autosar.mm.sl2mm.utils.DaVinciLUT.setLUTExternalInfoToM3iElement(...
                toolIDString,m3iStructElementSeq.at(bpIndex));
            end
        end

        function setLUTExternalInfoToM3iElement(toolIDString,m3iElement)
            externalToolName=autosar.mm.sl2mm.utils.DaVinciLUT.ExternalToolName;
            if m3iElement.isvalid()
                autosar.mm.Model.setExtraExternalToolInfo(m3iElement,...
                externalToolName,{'%s'},{toolIDString});
            end
        end

        function setLUTMajorityExternalInfo(toolIDString,m3iElement)
            externalToolName=autosar.mm.sl2mm.utils.DaVinciLUT.MajorityExternalToolName;
            if m3iElement.isvalid()
                autosar.mm.Model.setExtraExternalToolInfo(m3iElement,...
                externalToolName,{'%s'},{toolIDString});
            end
        end

        function externalToolID=getExternalToolID(m3iStructElement,externalToolName)
            externalToolInfo=m3iStructElement.getExternalToolInfo(externalToolName);
            externalToolID=externalToolInfo.externalId;
        end

        function assertM3iStructType(m3iStructImpType)
            assert(isa(m3iStructImpType,'Simulink.metamodel.types.Structure'),...
            "Expect Type to be a structure");
        end
    end
end


