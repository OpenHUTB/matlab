classdef LUTSolutionToModelAdapter





    properties(Constant)
        BlockName=message('SimulinkFixedPoint:functionApproximation:approximateSubsystemName').getString();
        RepeatingSequencePath='simulink/Sources/Repeating Sequence Stair';
        ScopePath='simulink/Sinks/Scope';
        DescriptionText=message('SimulinkFixedPoint:functionApproximation:approximateDescription').getString();
    end

    methods
        function modelInfo=getModel(this,lutSolution)

            lutModelData=FunctionApproximation.internal.Utils.getLUTDataForApproximateFunction(lutSolution);
            problemObject=lutSolution.SourceProblem;


            dataToModelAdapter=FunctionApproximation.internal.datatomodeladapter.getDataToModelAdapter(lutModelData);
            modelInfo=dataToModelAdapter.getModelInfo(lutModelData);
            modelInfo=transferData(this,lutSolution,modelInfo,lutModelData);
            if problemObject.Options.AUTOSARCompliant
                context=FunctionApproximation.internal.autosar.getLUTComplianceContext(problemObject);
                modelInfo=setToAUTOSAR(this,context,modelInfo);
            end
            if problemObject.Options.HDLOptimized
                modelInfo=setOutOfRangeDetection(this,modelInfo,lutModelData);
            end

            for ii=1:problemObject.NumberOfInputs
                set_param(modelInfo.getSignalSpecificationPath(ii),'OutMin',fixed.internal.compactButAccurateNum2Str(problemObject.InputLowerBounds(ii)));
                set_param(modelInfo.getSignalSpecificationPath(ii),'OutMax',fixed.internal.compactButAccurateNum2Str(problemObject.InputUpperBounds(ii)));
            end


            inputBlockPositions=modelInfo.getInputBlockPositions();
            for ii=1:problemObject.NumberOfInputs
                delete_block(getInputPath(modelInfo,ii))
                add_block(this.RepeatingSequencePath,getInputPath(modelInfo,ii),'Position',inputBlockPositions(ii,:));
                set_param(getInputPath(modelInfo,ii),'OutValues',[modelInfo.InputValuesVariableName,'(:,',int2str(ii),')']);
                if lutSolution.Options.Interpolation=="None"
                    set_param(getInputPath(modelInfo,ii),'OutDataTypeStr',problemObject.InputTypes(ii).tostring());
                end
            end


            gridCreator=FunctionApproximation.internal.gridcreator.MaximumPointsGridingStrategy(problemObject.InputTypes);
            rangeObject=FunctionApproximation.internal.Range(problemObject.InputLowerBounds,problemObject.InputUpperBounds);
            gridCell=getGrid(gridCreator,rangeObject);
            coordinateSets=FunctionApproximation.internal.CoordinateSetCreator(gridCell).CoordinateSets;
            modelInfo.ModelWorkspace.assignin(modelInfo.InputValuesVariableName,coordinateSets);
            modelInfo.ModelObject.StopTime=['size(',modelInfo.InputValuesVariableName,',1) - 1'];


            outputBlockObject=get_param(getOutputBlockPath(modelInfo),'Object');
            outputPosition=outputBlockObject.Position;
            delete_block(getOutputBlockPath(modelInfo));
            add_block(this.ScopePath,getOutputBlockPath(modelInfo),'Position',outputPosition);
            set_param(getOutputBlockPath(modelInfo),'OpenAtSimulationStart','off');


            screenSize=get(0,'ScreenSize');
            modelLocation=zeros(size(screenSize));
            modelLocation(1)=screenSize(3)*0.1;
            modelLocation(2)=screenSize(4)*0.1;
            modelLocation(3)=screenSize(3)*0.8;
            modelLocation(4)=screenSize(4)*0.8;
            modelInfo.ModelObject.Location=modelLocation;



            modelInfo.ModelObject.ShowPortDataTypes='on';
            modelInfo.ModelObject.ShowDesignRanges='on';
            set_param([modelInfo.ModelName,'/',modelInfo.SourceBlockName],'Name','LUT');
            if lutSolution.Options.HDLOptimized


                delayHandles=modelInfo.getDelayBlockHandles();
                modelInfo.turnDelaysOn();
                Simulink.BlockDiagram.expandSubsystem([modelInfo.ModelName,'/LUT'],'CreateArea','Off')
            end
            Simulink.BlockDiagram.createSubsystem(modelInfo.getBlockHandlesForInternalBlocks());
            if lutSolution.Options.HDLOptimized


                modelInfo.setCommentState(delayHandles,'through');
            end


            set_param([modelInfo.ModelName,'/Subsystem'],'Name',getBlockName(this));
            approximateObject=get_param([modelInfo.ModelName,'/',getBlockName(this)],'Object');
            approximateObject.Description=this.DescriptionText;
            approximateObject.Position=approximateObject.Position-[modelInfo.InputBlockWidth*0.5,0,-modelInfo.InputBlockWidth*0.5,0];

            outputBlockObject=get_param(getOutputBlockPath(modelInfo),'Object');
            for ii=1:problemObject.NumberOfInputs
                delete_line(modelInfo.ModelName,[getInputBlockName(modelInfo,ii),'/1'],[approximateObject.Name,'/',int2str(ii)]);
            end
            delete_line(modelInfo.ModelName,[approximateObject.Name,'/1'],[outputBlockObject.Name,'/1']);

            for ii=1:problemObject.NumberOfInputs
                inputBlockObject=get_param(getInputPath(modelInfo,ii),'Object');
                currentOutputPosition=inputBlockObject.Position;
                inputBlockObject.Position=[...
                approximateObject.Position(1)-modelInfo.InputBlockSpacing*3-(currentOutputPosition(3)-currentOutputPosition(1))...
                ,inputBlockObject.Position(2)...
                ,approximateObject.Position(1)-modelInfo.InputBlockSpacing*3...
                ,inputBlockObject.Position(4)];
            end

            for ii=1:problemObject.NumberOfInputs
                add_line(modelInfo.ModelName,[getInputBlockName(modelInfo,ii),'/1'],[approximateObject.Name,'/',int2str(ii)]);
            end
            add_line(modelInfo.ModelName,[approximateObject.Name,'/1'],[outputBlockObject.Name,'/1']);

            firstInputPosition=get_param(getInputPath(modelInfo,1),'Position');
            lastInputPosition=get_param(getInputPath(modelInfo,problemObject.NumberOfInputs),'Position');
            newPos=approximateObject.Position;
            heightOfApproximate=(lastInputPosition(4)-firstInputPosition(2));
            newPos(2)=firstInputPosition(2)+(heightOfApproximate*(problemObject.NumberOfInputs~=1)*0.25);
            newPos(4)=newPos(2)+(heightOfApproximate*((problemObject.NumberOfInputs~=1)*0.5+(problemObject.NumberOfInputs==1)*1));
            approximateObject.Position=newPos;


            currentOutputPosition=outputBlockObject.Position;
            outputBlockObject.Position=[...
            approximateObject.Position(3)+modelInfo.InputBlockSpacing*5...
            ,approximateObject.Position(2)...
            ,approximateObject.Position(3)+modelInfo.InputBlockSpacing*5+(currentOutputPosition(3)-currentOutputPosition(1))...
            ,approximateObject.Position(4)];



            outputPosition=get_param(getOutputBlockPath(modelInfo),'Position');
            note=Simulink.Annotation([modelInfo.ModelName,'/',message('SimulinkFixedPoint:functionApproximation:scopeResults').getString()]);
            noteLeftCoordinate=(outputPosition(3)+outputPosition(1))/2-(note.Position(3)-note.Position(1))/2;
            noteTopCoordinate=outputPosition(2)-modelInfo.InputBlockSpacing;
            newPosition=[noteLeftCoordinate,noteTopCoordinate,noteLeftCoordinate+note.Position(3),noteTopCoordinate+note.Position(4)];
            note.Position=newPosition;

            set_param(modelInfo.ModelName,'Zoomfactor','fit to view');
            blockPath=[modelInfo.ModelName,'/',getBlockName(this)];
            set_param(blockPath,'Zoomfactor','fit to view');
            warningStruct=warning('OFF','diagram_autolayout:autolayout:layoutRejectedCommandLine');
            Simulink.BlockDiagram.arrangeSystem(blockPath);
            warning(warningStruct);
            if lutSolution.Options.HDLOptimized
                set_param(blockPath,'Tag','HDLOptimized');
            end
            modelInfo.dirtyOff();
        end
    end

    methods
        function blockName=getBlockName(this)
            blockName=this.BlockName;
        end

        function modelInfo=transferData(~,lutSolution,modelInfo,lutModelData)
            if lutSolution.Options.Interpolation=="None"









                param=slprivate('modelWorkspaceGetVariableHelper',modelInfo.ModelWorkspace,modelInfo.ParameterObjectName);
                dataTypeContainer=FunctionApproximation.internal.Utils.dataTypeParser(param.DataType);
                if isFloat(dataTypeContainer)
                    values=param.Value;
                    if isSingle(dataTypeContainer)
                        values=single(values);
                    end
                    stringValues=FunctionApproximation.internal.ndmat2str(values,'class');
                else
                    storedIntegerValues=storedIntegerToDouble(fi(param.Value,dataTypeContainer.ResolvedType,'RoundMode','Floor'));
                    storedIntegerString=FunctionApproximation.internal.ndmat2str(storedIntegerValues);
                    dataTypeString=tostring(fixed.internal.type.extractNumericType(dataTypeContainer.ResolvedType));
                    stringValues=sprintf('fi(''numerictype'', %s, ''int'', %s)',dataTypeString,storedIntegerString);
                end
                set_param(modelInfo.getBlockPath(),'Table',stringValues);
                modelInfo.ModelWorkspace.clear(modelInfo.ParameterObjectName);
                set_param(modelInfo.getBlockPath(),'DiagnosticForOutOfRangeInput','Error');


                for ii=1:lutSolution.SourceProblem.NumberOfInputs
                    if lutModelData.NeedsLowerBoundCorrection(ii)
                        lbCorrectionBlockPath=modelInfo.getLowerBoundCorrectionBlockPath(ii);
                        value=slResolve(get_param(lbCorrectionBlockPath,'Value'),lbCorrectionBlockPath);
                        set_param(lbCorrectionBlockPath,'Value',fixed.internal.compactButAccurateNum2Str(value));
                    end
                end
                modelInfo.ModelWorkspace.clear(modelInfo.LowerBoundVarName);
            else
                if lutModelData.HDLOptimized
                    modelInfo.moveDataToBlocksFromModelWorkspace(lutModelData);
                else









                    lutBlockDataHandler=FunctionApproximation.internal.LookupNDBlockDataHandler();
                    lutBlockDataHandler.transferDataToBlock(modelInfo.getBlockPath(),modelInfo.ModelWorkspace.getVariable(modelInfo.LookupTableObjectName));
                    modelInfo.ModelWorkspace.clear(modelInfo.LookupTableObjectName);
                end
            end
        end

        function modelInfo=setToAUTOSAR(~,context,modelInfo)
            autosarLUT=[modelInfo.ModelName,'/tmp'];
            if context.NumInputs==1
                add_block('autosarlibiflifx/Curve',autosarLUT)
            else
                add_block('autosarlibiflifx/Map',autosarLUT)
            end
            originalBlock=[modelInfo.ModelName,'/',modelInfo.SourceBlockName];
            autosarBlockObject=get_param(autosarLUT,'Object');
            originalBlockObject=get_param(originalBlock,'Object');
            dparams=originalBlockObject.DialogParameters;
            fNames=fieldnames(dparams);
            for iName=1:numel(fNames)
                try
                    autosarBlockObject.(fNames{iName})=originalBlockObject.(fNames{iName});
                catch
                end
            end
            FunctionApproximation.internal.Utils.replaceBlockWithBlock(originalBlock,autosarLUT);
            delete_block(autosarLUT);

            for iInput=1:context.NumInputs
                parameterName="BreakpointsForDimension"+string(int2str(iInput))+"DataTypeStr";
                set_param(originalBlock,parameterName,...
                "Inherit: Same as corresponding input");
            end

            set_param(originalBlock,'TargetRoutineLibrary',context.TargetRoutineLibrary);
            set_param(modelInfo.ModelName,'SystemTargetFile','autosar.tlc');
            set_param(modelInfo.ModelName,'CodeReplacementLibrary','AUTOSAR 4.0');
        end

        function modelInfo=setOutOfRangeDetection(~,modelInfo,modelData)


            directLUBlockPath=modelInfo.getPathForTableValueLU();
            set_param(directLUBlockPath,'DiagnosticForOutOfRangeInput','Error');
            if strcmp(modelData.InterpolationMethod,'linear')
                directLUBlockPathDeltaTV=modelInfo.getPathForDeltaTableValueLU();
                set_param(directLUBlockPathDeltaTV,'DiagnosticForOutOfRangeInput','Error');
            end
        end
    end
end
