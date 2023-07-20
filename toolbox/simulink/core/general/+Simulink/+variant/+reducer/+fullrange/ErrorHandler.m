classdef(Sealed,Hidden)ErrorHandler







    methods(Static,Hidden,Access=public)


        function handleErrors(modelName,errors)
            if isempty(errors)
                return;
            end
            msg=[];
            for i=1:numel(errors)
                if isa(errors,'cell')
                    msg=[msg,newline,errors{i}.message];%#ok<AGROW>
                else
                    msg=[msg,newline,errors(i).message];%#ok<AGROW>
                end
            end
            headerMsg=message('Simulink:VariantReducer:FullRangeHeader',modelName,msg);
            err=MException(headerMsg);
            throwAsCaller(err);
        end




        function ensureAACONAndNOMRVForAllFullRangeBlocks(modelName,varNamesFullRangeCtrlVar,varControlVarsToBlocksMap,rootModelPathToRefModelPathMap)
            errors=[];
            AACOFFBlocks=containers.Map();
            MRVBlocks=containers.Map();


            for i=1:numel(varNamesFullRangeCtrlVar)
                blocks=varControlVarsToBlocksMap(varNamesFullRangeCtrlVar{i});
                for j=1:numel(blocks)
                    if Simulink.variant.reducer.utils.isAnalyzeAllChoicesDisabled(rootModelPathToRefModelPathMap(blocks{j}))
                        i_addKeyValueToMap(AACOFFBlocks,varNamesFullRangeCtrlVar{i},rootModelPathToRefModelPathMap(blocks{j}));
                    end
                    if strcmp(get_param(rootModelPathToRefModelPathMap(blocks{j}),'BlockType'),'ModelReference')
                        i_addKeyValueToMap(MRVBlocks,varNamesFullRangeCtrlVar{i},rootModelPathToRefModelPathMap(blocks{j}));
                    end
                end
            end
            varsWithMRVBlocks=MRVBlocks.keys;
            for i=1:numel(varsWithMRVBlocks)
                err=MException(message('Simulink:VariantReducer:FullRangeModelVariantsUnsupported',...
                i_cell2str(MRVBlocks(varsWithMRVBlocks{i})),varsWithMRVBlocks{i}));
                errors=[errors,err];%#ok<AGROW>
            end
            Simulink.variant.reducer.fullrange.ErrorHandler.handleErrors(modelName,errors);

            varsWithAACOFFBlocks=AACOFFBlocks.keys;
            for i=1:numel(varsWithAACOFFBlocks)
                msgid='Simulink:VariantReducer:FullRangeBlocksAACOff';
                err=MException(message(msgid,...
                i_cell2str(AACOFFBlocks(varsWithAACOFFBlocks{i})),varsWithAACOFFBlocks{i}));
                errors=[errors,err];%#ok<AGROW>
            end
            Simulink.variant.reducer.fullrange.ErrorHandler.handleErrors(modelName,errors);
        end




        function ensureAACONAllFullRangeBlocks(modelName,varNamesFullRangeCtrlVar,variableUsageInfo)
            errors=[];
            AACOFFBlocks=containers.Map();
            MRVBlocks=containers.Map();


            for i=1:numel(varNamesFullRangeCtrlVar)
                blockPaths=variableUsageInfo(varNamesFullRangeCtrlVar{i});
                blocks={blockPaths.ParentModelPath};
                for j=1:numel(blocks)
                    if any(strcmp(get_param(blocks{j},'BlockType'),{'VariantSource','VariantSink','Subsystem'}))&&...
                        Simulink.variant.reducer.utils.isAnalyzeAllChoicesDisabled(blocks{j})
                        i_addKeyValueToMap(AACOFFBlocks,varNamesFullRangeCtrlVar{i},blocks{j});
                    end
                    if strcmp(get_param(blocks{j},'BlockType'),'ModelReference')
                        i_addKeyValueToMap(MRVBlocks,varNamesFullRangeCtrlVar{i},blocks{j});
                    end
                end
            end
            varsWithAACOFFBlocks=AACOFFBlocks.keys;
            for i=1:numel(varsWithAACOFFBlocks)
                msgid='Simulink:VariantReducer:FullRangeBlocksAACOff';
                err=MException(message(msgid,...
                i_cell2str(AACOFFBlocks(varsWithAACOFFBlocks{i})),varsWithAACOFFBlocks{i}));
                errors=[errors,err];%#ok<AGROW>
            end
            Simulink.variant.reducer.fullrange.ErrorHandler.handleErrors(modelName,errors);
        end



        function handleDependentFullRangeVarsInSameBlock(blocksUsingFullRangeVars,blocksToVarControlVarsMap)
            if numel(blocksUsingFullRangeVars)==numel(unique(blocksUsingFullRangeVars))

                return;
            end



            blocksVarsCountMap=containers.Map();
            repeatedFullRangeVarBlocks={};
            for i=1:numel(blocksUsingFullRangeVars)
                if~blocksVarsCountMap.isKey(blocksUsingFullRangeVars{i})
                    blocksVarsCountMap(blocksUsingFullRangeVars{i})=true;
                else
                    repeatedFullRangeVarBlocks=[repeatedFullRangeVarBlocks,blocksUsingFullRangeVars{i}];%#ok<AGROW>
                end
            end
            msgStr='';
            for j=1:numel(repeatedFullRangeVarBlocks)
                msgStr=[msgStr,'',repeatedFullRangeVarBlocks{j}...
                ,': {',i_cell2str(blocksToVarControlVarsMap(repeatedFullRangeVarBlocks{j})),'}',newline];%#ok<AGROW>
            end
            msgStr(end)=[];
            msg=message('Simulink:VariantReducer:FullRangeDependentVarsSameBlock',msgStr);
            err=MException(msg);
            throwAsCaller(err);
        end
    end
end


function i_addKeyValueToMap(map,key,value)
    Simulink.variant.utils.i_addKeyValueWithDupsToMap(map,key,value)
end



function str=i_cell2str(x)
    str=Simulink.variant.utils.i_cell2str(x);
end


