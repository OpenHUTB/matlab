classdef LUTSolutionToApproximationBlockModelAdapter<FunctionApproximation.internal.LUTSolutionToModelAdapter






    methods
        function modelInfo=getModel(this,lutSolution)
            modelInfo=getModel@FunctionApproximation.internal.LUTSolutionToModelAdapter(this,lutSolution);
            blockObject=get_param([modelInfo.ModelName,'/',this.getBlockName()],'Object');
            schema=FunctionApproximation.internal.approximationblock.BlockSchema();
            variableNames=string.empty();
            nInputs=lutSolution.SourceProblem.NumberOfInputs;
            if lutSolution.SourceProblem.InputFunctionType.isBlock()


                curDir=pwd;
                handler=lutSolution.SourceProblem.TemporaryModelHandler;
                loadModel(handler);
                functionToReplaceWith=getSourceBlockPath(handler);
                functionToReplaceIsRedesignable=FunctionApproximation.internal.approximationblock.isCreatedByFunctionApproximation(functionToReplaceWith);
                if functionToReplaceIsRedesignable


                    functionToReplaceWith=schema.getOriginalSource(functionToReplaceWith);
                end
                cleanupModel=onCleanup(@()close_system(handler.ModelName,0));
                cd(curDir);


                modelObject=get_param(modelInfo.ModelName,'Object');
                modelWorkspace=modelObject.ModelWorkSpace;
                originalModel=get_param(bdroot(functionToReplaceWith),'Object');
                workspace=originalModel.ModelWorkspace;
                dataNames=setdiff({workspace.data.Name},{modelWorkspace.data.Name});
                data=workspace.data;
                for iData=1:numel(data)
                    if ismember(data(iData).Name,dataNames)
                        modelWorkspace.assignin(data(iData).Name,data(iData).Value);
                    end
                end
                modelObject.DataDictionary=originalModel.DataDictionary;
                variableNames=string({modelWorkspace.data.Name});
            else



                k=new_system;
                tempModelName=get_param(k,'Name');
                load_system(k);
                cleanupObject=onCleanup(@()close_system(tempModelName,0));
                tempBlockPath=[tempModelName,'/Original'];
                add_block('simulink/User-Defined Functions/Interpreted MATLAB Function',tempBlockPath)


                if isa(lutSolution.SourceProblem.FunctionToApproximate,'cfit')
                    curvefitHandleGenerator=FunctionApproximation.internal.CurveFitFunctionHandleGenerator(lutSolution.SourceProblem.FunctionToApproximate);
                    standardizedFunctionHandle=curvefitHandleGenerator.FunctionHandle;
                    modelInfo.ModelWorkspace.assignin(curvefitHandleGenerator.CurveFitObj,lutSolution.SourceProblem.FunctionToApproximate);
                else
                    standardizedFunctionHandle=FunctionApproximation.internal.StandardFunctionHandleGenerator(lutSolution.SourceProblem.FunctionToApproximate);
                end
                functionString=func2str(standardizedFunctionHandle.FunctionHandle);
                stringForBlock=functionString(5:end);
                stringForBlock=strrep(stringForBlock,'x(:,','u(');
                set_param(tempBlockPath,'MATLABFcn',stringForBlock);
                blockHandles(1)=get_param(tempBlockPath,'Handle');
                if nInputs>1


                    muxPath=[tempModelName,'/Mux'];
                    add_block('simulink/Commonly Used Blocks/Mux',muxPath);
                    add_line(tempModelName,'Mux/1','Original/1');
                    blockHandles(end+1)=get_param(muxPath,'Handle');
                    set_param(blockHandles(end),'Inputs',int2str(nInputs))
                end


                warnStruct=warning('OFF','diagram_autolayout:autolayout:layoutRejectedCommandLine');
                Simulink.BlockDiagram.arrangeSystem(tempModelName);
                warning(warnStruct);


                Simulink.BlockDiagram.createSubsystem(blockHandles);
                functionToReplaceWith=[tempModelName,'/Subsystem'];
                openBracketLocation=strfind(stringForBlock,'(');
                displayFunctionName=stringForBlock(1:openBracketLocation(1)-1);
                set_param(functionToReplaceWith,'MaskDisplay',"fprintf('%s','"+string(displayFunctionName)+"')");
            end

            blockPath=blockObject.getFullName();
            approximationBlockInfo=FunctionApproximation.internal.approximationblock.createApproximationBlock(blockPath,1);
            FunctionApproximation.internal.Utils.replaceBlockWithBlock(schema.getOriginalSource(approximationBlockInfo.BlockPath),functionToReplaceWith);
            set_param(approximationBlockInfo.BlockPath,'Description',this.DescriptionText);

            if lutSolution.SourceProblem.InputFunctionType=="MathBlock"||...
                ~lutSolution.SourceProblem.InputFunctionType.isBlock()





                originalVariantPath=schema.getNameForOriginal(approximationBlockInfo.BlockPath);
                for ii=1:nInputs
                    dtcPath=[originalVariantPath,'/',schema.getInputDTCName(ii)];
                    set_param(dtcPath,'Commented','off');
                end
            end

            if lutSolution.Options.SaturateToOutputType




                originalVariantPath=schema.getNameForOriginal(approximationBlockInfo.BlockPath);
                saturationPath=[originalVariantPath,'/',schema.getOutputSaturationName(1)];
                set_param(saturationPath,'Commented','off');
                r=fixed.internal.type.finiteRepresentableRange(lutSolution.SourceProblem.OutputType);
                set_param(saturationPath,'LowerLimit',fixed.internal.compactButAccurateNum2Str(r(1)));
                set_param(saturationPath,'UpperLimit',fixed.internal.compactButAccurateNum2Str(r(2)));
            end

            text=FunctionApproximation.internal.approximationblock.getProblemDescriptionForApproximationBlock(lutSolution.SourceProblem);
            detailsDialog=approximationBlockInfo.MaskObject.getDialogControl('detailsText');
            detailsDialog.Prompt=text;


            problemStruct=FunctionApproximation.internal.Utils.getStructFromProblem(lutSolution.SourceProblem);
            problemStruct.DependentVariables=variableNames;
            problemStructParameter=approximationBlockInfo.MaskObject.addParameter('Type','textarea','Name',schema.ProblemStructParameterName);
            problemStructParameter.Value=jsonencode(problemStruct);
            problemStructParameter.Hidden='on';
            problemStructParameter.Visible='off';
            problemStructParameter.ReadOnly='on';


            dialogControlRedesign=approximationBlockInfo.MaskObject.addDialogControl('pushbutton',schema.RedesignParameterName);
            dialogControlRedesign.Callback=schema.getCallbackForRedesign(approximationBlockInfo.InternalTag);
            dialogControlRedesign.Prompt=schema.RedesignPrompt;
            dialogControlRedesign.Tooltip=schema.RedesignTooltip;
            dialogControlRedesign.Row='new';


            loadCompareContext(lutSolution);
            dataContext=lutSolution.CompareContext;
            compareDataParameter=approximationBlockInfo.MaskObject.addParameter('Type','textarea','Name',schema.CompareDataParameterName);
            compareDataParameter.Value=jsonencode(dataContext);
            compareDataParameter.Hidden='on';
            compareDataParameter.Visible='off';
            compareDataParameter.ReadOnly='on';


            dialogControlCompare=approximationBlockInfo.MaskObject.addDialogControl('pushbutton',schema.CompareParameterName);
            dialogControlCompare.Callback=schema.getCallbackForCompare(approximationBlockInfo.InternalTag);
            dialogControlCompare.Prompt=schema.ComparePrompt;
            dialogControlCompare.Tooltip=schema.CompareTooltip;
            dialogControlCompare.Row='current';

            if lutSolution.Options.Interpolation=="None"


















                delayBlocks=Simulink.findBlocksOfType(schema.getNameForApproximate(approximationBlockInfo.BlockPath,1),'Delay');
                delayBlockPaths=arrayfun(@(x)Simulink.ID.getFullName(x),delayBlocks,'UniformOutput',false);
                inputDelayPrefix=FunctionApproximation.internal.datatomodeladapter.DirectLUModelInfo.InputDelayPrefix;
                inputDelays=contains(delayBlockPaths,inputDelayPrefix);
                outputDelays=~inputDelays;

                delayBlockPaths=strrep(delayBlockPaths,[approximationBlockInfo.BlockPath,'/'],'');
                inputDelayPaths=delayBlockPaths(inputDelays);
                outputDelayPaths=delayBlockPaths(outputDelays);
                outputDelayPaths=outputDelayPaths(~contains(outputDelayPaths,schema.getOutputLatencyDelayName(1)));


                if~isempty(inputDelayPaths)
                    approximationBlockInfo.MaskObject.addParameter(...
                    'Type','promote',...
                    'TypeOptions',strcat(inputDelayPaths,'/DelayLength'),...
                    'Name',schema.DelayBeforeLookupParamterName,...
                    'Prompt',schema.DelayBeforeLookupPrompt,...
                    'Value','0');
                end

                approximationBlockInfo.MaskObject.addParameter(...
                'Type','promote',...
                'TypeOptions',strcat(outputDelayPaths,'/DelayLength'),...
                'Name',schema.DelayAfterLookupParamterName,...
                'Prompt',schema.DelayAfterLookupPrompt,...
                'Value','0');

                approximationBlockInfo.MaskObject.addParameter(...
                'Type','promote',...
                'TypeOptions',strcat(outputDelayPaths,'/InitialCondition'),...
                'Name',schema.InitialConditionDelayAfterLookupParameterName,...
                'Prompt',schema.InitialConditionDelayAfterLookupPrompt,...
                'Value','0');
            end

            if lutSolution.Options.HDLOptimized
                approximationBlockInfo.MaskObject.addParameter(...
                'Type','checkbox',...
                'Name',schema.SimulateWithDelayParameterName,...
                'Prompt',schema.SimulateWithDelayPrompt,...
                'Value','off',...
                'Callback',schema.getCallbackForSimulateWithDelay());

                latency=FunctionApproximation.internal.datatomodeladapter.HDLLUTModelInfo.getLatency(lutSolution.Options.Interpolation);

                approximationBlockInfo.MaskObject.addParameter(...
                'Type','textarea',...
                'Name',schema.LatencyParameterName,...
                'Value',int2str(latency),...
                'Visible','off');





                originalVariantPath=schema.getNameForOriginal(approximationBlockInfo.BlockPath);
                delayPath=[originalVariantPath,'/',schema.getOutputLatencyDelayName(1)];
                set_param(delayPath,'Commented','off');
                set_param(delayPath,'DelayLength',int2str(latency));
            end

            this.removeCommentedBlocks(schema.getNameForOriginal(approximationBlockInfo.BlockPath));
            this.removeCommentedBlocks(schema.getNameForApproximate(approximationBlockInfo.BlockPath,1));

            if lutSolution.Options.HDLOptimized
                set_param(approximationBlockInfo.BlockPath,schema.SimulateWithDelayParameterName,'off')
            end
        end
    end

    methods(Hidden)
        function removeCommentedBlocks(this,variantPath)








            findOption=Simulink.FindOptions('SearchDepth',1);
            allBlocks=Simulink.findBlocks(variantPath,findOption);
            findOption.IncludeCommented=false;
            uncommentedBlocks=Simulink.findBlocks(variantPath,findOption);
            commentedBlocks=setdiff(allBlocks,uncommentedBlocks);
            if~isempty(commentedBlocks)








                currentBlock=commentedBlocks(1);
                connectivity=get_param(currentBlock,'PortConnectivity');
                lineHandles=get_param(currentBlock,'LineHandles');
                delete_line(lineHandles.Outport(1));
                delete_line(lineHandles.Inport(1));
                sourceHandle=connectivity(1).SrcBlock;
                sourcePort=connectivity(1).SrcPort+1;
                destinationHandle=connectivity(2).DstBlock;
                destinationPort=connectivity(2).DstPort+1;
                sourcePortString=strrep(Simulink.ID.getFullName(sourceHandle),[variantPath,'/'],'');
                sourcePortString=[sourcePortString,'/',int2str(sourcePort)];
                destinationPortString=strrep(Simulink.ID.getFullName(destinationHandle),[variantPath,'/'],'');
                destinationPortString=[destinationPortString,'/',int2str(destinationPort)];
                add_line(variantPath,sourcePortString,destinationPortString);
                delete_block(currentBlock);

                removeCommentedBlocks(this,variantPath);
            end
        end
    end
end

