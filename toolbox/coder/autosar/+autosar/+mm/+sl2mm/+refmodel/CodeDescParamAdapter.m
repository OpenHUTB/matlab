classdef CodeDescParamAdapter<handle








    properties(Access=private)
        ParamNameToCodeDescParamInfoMap;
        CodeDescriptorCache;
    end

    methods(Access=public)
        function this=CodeDescParamAdapter(codeDescObj,codeDescCache)
            this.CodeDescriptorCache=codeDescCache;
            this.ParamNameToCodeDescParamInfoMap=this.walkModelHierarchy(codeDescObj);
        end

        function codeDescParamInfo=getCodeDescParamInfo(this,topModelParam)


            topModelParamName=topModelParam.GraphicalName;
            assert(this.ParamNameToCodeDescParamInfoMap.isKey(topModelParamName),...
            sprintf('Expect top model param name: %s to be present in CodeDescParamAdapter',...
            topModelParamName));
            codeDescParamInfo=this.ParamNameToCodeDescParamInfoMap(topModelParamName);
        end

    end

    methods(Access=private)

        function modelCodeDescParamInfoMap=walkModelHierarchy(this,codeDescObj)





            modelCodeDescParamInfoMap=this.getModelParamInfoMap(codeDescObj);

            blockHierarchyMap=codeDescObj.getBlockHierarchyMap;
            if isempty(blockHierarchyMap)
                return;
            end

            modelRefBlocks=blockHierarchyMap.getBlocksByType('ModelReference');

            for blockIdx=1:numel(modelRefBlocks)
                modelRefBlock=modelRefBlocks(blockIdx);

                refModelName=modelRefBlock.ReferencedModelName;
                refModelCodeDescObj=...
                this.CodeDescriptorCache.getRefModelCodeDescriptor(refModelName,codeDescObj);


                childModelParamInfoMap=this.walkModelHierarchy(refModelCodeDescObj);


                pulledCodeDescParamInfos=this.pullParamsUp(modelRefBlock,childModelParamInfoMap);



                for pulledParamIdx=1:numel(pulledCodeDescParamInfos)
                    codeDescParamInfo=pulledCodeDescParamInfos{pulledParamIdx};
                    this.verifyCodeDescParamInfoCompatibility(codeDescParamInfo,...
                    modelCodeDescParamInfoMap);
                    modelCodeDescParamInfoMap(codeDescParamInfo.GraphicalName)=codeDescParamInfo;
                end
            end
        end
    end

    methods(Access=private,Static)

        function paramInfoMap=getModelParamInfoMap(codeDescObj)


            paramInfoMap=containers.Map();
            codeDescParams=codeDescObj.getDataInterfaces('Parameters');
            for paramIdx=1:numel(codeDescParams)
                codeDescParam=codeDescParams(paramIdx);
                lutParamInfo=autosar.mm.sl2mm.refmodel.CodeDescParamInfo(codeDescParam);

                if autosar.mm.sl2mm.LookupTableBuilder.isComAxisLookupTable(codeDescParam)

                    codeDescBPs=codeDescParam.Breakpoints;
                    numberOfBreakpoints=codeDescBPs.Size();
                    lutParamInfo.BreakpointNames=cell(numberOfBreakpoints,1);

                    for bpIndex=1:numberOfBreakpoints
                        codeDescBPParam=codeDescBPs(bpIndex);
                        lutParamInfo.BreakpointNames{bpIndex}=codeDescBPParam.GraphicalName;
                        bpParamInfo=autosar.mm.sl2mm.refmodel.CodeDescParamInfo(codeDescBPParam);
                        autosar.mm.sl2mm.refmodel.CodeDescParamAdapter.verifyCodeDescParamInfoCompatibility(...
                        bpParamInfo,paramInfoMap);
                        paramInfoMap(bpParamInfo.GraphicalName)=bpParamInfo;
                    end
                end

                autosar.mm.sl2mm.refmodel.CodeDescParamAdapter.verifyCodeDescParamInfoCompatibility(...
                lutParamInfo,paramInfoMap);
                paramInfoMap(lutParamInfo.GraphicalName)=lutParamInfo;



                [isFixAxisLUT,isEvenSpacingLUT]=...
                autosar.mm.sl2mm.LookupTableBuilder.hasFixAxisLookupTableDataInterface(codeDescParam);
                if isEvenSpacingLUT&&~isFixAxisLUT

                    codeDescBPs=codeDescParam.Breakpoints;
                    for bpIndex=1:codeDescBPs.Size()
                        codeDescBPParam=codeDescBPs(bpIndex);
                        if~codeDescBPParam.IsTunableBreakPoint
                            continue;
                        end
                        bpParamInfo=autosar.mm.sl2mm.refmodel.CodeDescParamInfo(codeDescBPParam);
                        autosar.mm.sl2mm.refmodel.CodeDescParamAdapter.verifyCodeDescParamInfoCompatibility(...
                        bpParamInfo,paramInfoMap);
                        paramInfoMap(bpParamInfo.GraphicalName)=bpParamInfo;
                    end
                end

            end
        end

        function verifyCodeDescParamInfoCompatibility(codeDescParamInfo,paramInfoMap)


            if~isKey(paramInfoMap,codeDescParamInfo.GraphicalName)
                return;
            end

            codeDescParam=codeDescParamInfo.CodeDescObj;
            if~isa(codeDescParam,'coder.descriptor.LookupTableDataInterface')&&...
                ~isa(codeDescParam,'coder.descriptor.BreakpointDataInterface')

                return;
            end



            existingCodeDescParamInfo=paramInfoMap(codeDescParamInfo.GraphicalName);
            existingCodeDescParam=existingCodeDescParamInfo.CodeDescObj;

            if~isa(existingCodeDescParam,'coder.descriptor.LookupTableDataInterface')&&...
                ~isa(existingCodeDescParam,'coder.descriptor.BreakpointDataInterface')


                return;
            end

            if metaclass(existingCodeDescParam)~=metaclass(codeDescParam)

                autosar.mm.sl2mm.refmodel.CodeDescParamAdapter.throwExceptionForIncompatibleParamInfo(...
                existingCodeDescParamInfo,codeDescParamInfo,'SameParamForLookupTableAndAxis','Error');
            end

            if isa(existingCodeDescParam,'coder.descriptor.LookupTableDataInterface')


                existingBpNames=existingCodeDescParamInfo.BreakpointNames;
                bpNames=codeDescParamInfo.BreakpointNames;

                if numel(bpNames)~=numel(existingBpNames)||~all(strcmp(bpNames,existingBpNames))||...
                    codeDescParam.Breakpoints.Size~=existingCodeDescParam.Breakpoints.Size
                    autosar.mm.sl2mm.refmodel.CodeDescParamAdapter.throwExceptionForIncompatibleParamInfo(...
                    existingCodeDescParamInfo,codeDescParamInfo,'LookupTableDataSharingRestriction','Warning');
                else

                    for bpIdx=1:codeDescParam.Breakpoints.Size
                        codeDescBp=codeDescParam.Breakpoints.at(bpIdx);
                        existingCodeDescBp=existingCodeDescParam.Breakpoints.at(bpIdx);
                        if~isequal(codeDescBp.FixAxisMetadata,existingCodeDescBp.FixAxisMetadata)||...
                            ~isequal(codeDescBp.Type.Name,existingCodeDescBp.Type.Name)


                            autosar.mm.sl2mm.refmodel.CodeDescParamAdapter.throwExceptionForIncompatibleParamInfo(...
                            existingCodeDescParamInfo,codeDescParamInfo,'LookupTableDataSharingRestriction','Warning');
                        end
                    end
                end
            end
        end

        function throwExceptionForIncompatibleParamInfo(codeDescParamInfo1,codeDescParamInfo2,identifier,errorType)



            import autosar.mm.sl2mm.refmodel.CodeDescParamAdapter.extractBlockPathFromCodeDescObj;
            codeDescParam1=codeDescParamInfo1.CodeDescObj;
            codeDescParam2=codeDescParamInfo2.CodeDescObj;

            getModelNameFromSID=@(sid)extractBefore(sid,':');

            existingParamModelName=getModelNameFromSID(codeDescParam1.SID);
            paramModelName=getModelNameFromSID(codeDescParam2.SID);

            if bdIsLoaded(existingParamModelName)&&bdIsLoaded(paramModelName)
                errorStr1=extractBlockPathFromCodeDescObj(codeDescParam1);
                errorStr2=extractBlockPathFromCodeDescObj(codeDescParam2);
            else
                identifier=strcat('RefModel',identifier);
                errorStr1=existingParamModelName;
                errorStr2=paramModelName;
            end

            msgStream=autosar.mm.util.MessageStreamHandler.instance();
            errorID=strcat('autosarstandard:exporter:',identifier);
            if strcmp(errorType,'Error')
                msgStream.createError(errorID,{codeDescParamInfo1.GraphicalName,errorStr1,errorStr2});
            elseif strcmp(errorType,'Warning')
                msgStream.createWarning(errorID,{codeDescParamInfo1.GraphicalName,errorStr1,errorStr2});
            else
                assert(false,'Unknown errorType');
            end
        end

        function blockPath=extractBlockPathFromCodeDescObj(codeDescParam)
            blockFullPath=getfullname(codeDescParam.SID);
            if contains(blockFullPath,newline)
                blockPath=extractBefore(blockFullPath,newline);
            else
                blockPath=blockFullPath;
            end
        end

        function pulledCodeDescParamInfos=pullParamsUp(modelRefBlock,refModelCodeDescParamInfoMap)



            pulledCodeDescParamInfos={};
            modelRefBlockCodeDescParams=modelRefBlock.BlockParameters;



            modelRefBlockParamNameMap=containers.Map();
            for paramIdx=1:modelRefBlockCodeDescParams.Size
                modelRefBlockCodeDescParam=modelRefBlockCodeDescParams(paramIdx);
                refModelParamName=modelRefBlockCodeDescParam.Name;


                codeDescModelParamSeq=modelRefBlockCodeDescParam.ModelParameters;
                if codeDescModelParamSeq.Size()==1&&...
                    codeDescModelParamSeq(1).WorkspaceVariable

                    modelParamName=codeDescModelParamSeq(1).WorkspaceVariableName;
                    modelRefBlockParamNameMap(refModelParamName)=modelParamName;
                else


                end
            end

            for modelRefBlockKey=keys(modelRefBlockParamNameMap)
                refModelParamName=modelRefBlockKey{1};

                if~isKey(refModelCodeDescParamInfoMap,refModelParamName)


                    continue;
                end

                modelParamName=modelRefBlockParamNameMap(refModelParamName);
                refModelCodeDescParamInfo=refModelCodeDescParamInfoMap(refModelParamName);
                if autosar.mm.sl2mm.LookupTableBuilder.isComAxisLookupTable(refModelCodeDescParamInfo.CodeDescObj)
                    [bpNames,isValidComAxisLUT]=...
                    autosar.mm.sl2mm.refmodel.CodeDescParamAdapter.resolveBreakpointNames(...
                    refModelCodeDescParamInfo,modelRefBlockParamNameMap);
                    if~isValidComAxisLUT
                        continue;
                    end
                    refModelCodeDescParamInfo.BreakpointNames=bpNames;
                end

                refModelCodeDescParamInfo.GraphicalName=modelParamName;
                pulledCodeDescParamInfos{end+1}=refModelCodeDescParamInfo;%#ok<AGROW>
            end

        end

        function[bpNames,isValidComAxisLUT]=resolveBreakpointNames(refModelCodeDescParamInfo,modelRefBlockParamNameMap)





            refModelBPNames=refModelCodeDescParamInfo.BreakpointNames;
            bpNames={};
            for bpIndex=1:numel(refModelBPNames)
                refModelBPName=refModelBPNames{bpIndex};
                if isKey(modelRefBlockParamNameMap,refModelBPName)
                    bpNames{end+1}=modelRefBlockParamNameMap(refModelBPName);%#ok<AGROW>
                end
            end
            isValidComAxisLUT=(numel(bpNames)==numel(refModelBPNames));
        end
    end

end


