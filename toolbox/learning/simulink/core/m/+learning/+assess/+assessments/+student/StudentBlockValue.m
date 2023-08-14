classdef StudentBlockValue<learning.assess.assessments.StudentAssessment




    properties(Constant)
        type='BlockValue';
        minTolerance=0.01;
    end

    properties
BlockType
ReferenceBlock
Value
        tolerance=0.05;
ReferenceSignal
    end

    methods
        function obj=StudentBlockValue(props)
            obj.validateInputProps(props);
            obj.hasPlot=true;

            obj.BlockType=props.BlockType;
            obj.ReferenceBlock=props.ReferenceBlock;
            answerStruct=load(props.SolutionFile);
            obj.Value=answerStruct.answer;

            if isfield(props,'ReferenceSignalFile')
                refSig=load(props.ReferenceSignalFile);

                refSig.referenceSignal.name=message(refSig.referenceSignal.name).getString();
                obj.ReferenceSignal=refSig.referenceSignal;
            end
        end

        function isCorrect=assess(obj,userModelName)
            isCorrect=false;

            obj.validateAssessProps();



            set_param(userModelName,'ReturnWorkspaceOutputs','off');
            set_param(userModelName,'SimscapeLogType','all');




            possibleBlockHandles=find_system(userModelName,'FindAll','on',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'BlockType',obj.BlockType,...
            'ReferenceBlock',obj.ReferenceBlock);
            if isempty(possibleBlockHandles)



                if~isempty(obj.ReferenceBlock)
                    learning.assess.throwWarningIfUsingWrongLibrary(userModelName,obj.ReferenceBlock);
                end
                return
            end



            modelStopFcn=get_param(userModelName,'StopFcn');
            stopFcn='learning.assess.stopFunction(gcs,gcb);';
            if contains(modelStopFcn,stopFcn)
                newStopFcn=strrep(modelStopFcn,stopFcn,'');
                set_param(userModelName,'StopFcn',newStopFcn);
            end



            try
                simOut=sim(userModelName,'ReturnWorkspaceOutputs','on');


                if isprop(simOut,'simlog')
                    assignin('base','simlog',simOut.simlog);
                end
                modelWarnings=simOut.SimulationMetadata.ExecutionInfo.WarningDiagnostics;
                if~isempty(modelWarnings)
                    sldiagviewer.reportSimulationMetadataDiagnostics(simOut);
                end
            catch err

                sldiagviewer.createStage('Analysis','ModelName',userModelName);
                sldiagviewer.reportError(err);
                return
            end


            if~isprop(simOut,'simlog')
                return
            end

            userStruct=struct('simlog',simOut.simlog,...
            'correctBlock',[]);
            userBlockValueFile=learning.assess.getAssessmentPlotLogFile();
            save(userBlockValueFile,'userStruct');
            possibleBlockNames=get_param(possibleBlockHandles,'Name');



            possibleBlockNames=obj.formatBlockName(possibleBlockNames);

            if~iscell(possibleBlockNames)
                possibleBlockNames={possibleBlockNames};
            end

            blockValueName=obj.Value.name;
            for i=1:length(possibleBlockNames)
                if~isprop(simOut.simlog,possibleBlockNames{i})
                    continue;
                end
                userBlockValueNode=simOut.simlog.(possibleBlockNames{i}).(blockValueName);
                userBlockValue=userBlockValueNode.series.values;
                userTimeSeries=simOut.simlog.(possibleBlockNames{i}).(blockValueName).series.time;



                userBlockValue=interp1(userTimeSeries,userBlockValue,obj.Value.time,'linear','extrap');




                acceptableDifference=repmat(obj.minTolerance,length(obj.Value.values),1);
                isSmallSignal=obj.Value.values.*obj.tolerance<=obj.minTolerance;
                acceptableDifference(~isSmallSignal)=abs(obj.Value.values(~isSmallSignal)).*obj.tolerance;

                if all(abs(obj.Value.values-userBlockValue)<acceptableDifference)
                    isCorrect=true;
                    userStruct.correctBlock=possibleBlockHandles(i);
                    save(userBlockValueFile,'userStruct');
                    break;
                end
            end
        end

        function requirementString=generateRequirementString(obj)
            fullBlockPath=strsplit(obj.ReferenceBlock,'/');
            blockName=fullBlockPath{end};
            blockType=strrep(blockName,newline,' ');
            blockNameText=[newline,'     ',blockType,': ',obj.Value.name];
            requirementString=message('learning:simulink:genericRequirements:blockValue',blockNameText).getString();
        end

        function writePlotFigure(obj,selectedBlockHandle,showFigureWindow)


            [fh,ah]=obj.getFigureHandle(selectedBlockHandle,showFigureWindow);
            hold on

            answerHandle=plot(ah,obj.Value.time,obj.Value.values,...
            'Color',[0.8235,0.4706,0.0353],'LineWidth',2);

            requirementStr=message('learning:simulink:resources:SignalFigureLegendRange').getString();
            signalStr=message('learning:simulink:resources:SignalFigureLegendSignal').getString();
            incorrectStr=message('learning:simulink:resources:SignalFigureLegendIncorrect').getString();

            legendPlots=answerHandle;
            legendTitles={requirementStr};
            fontSize=7.2;
            if~isempty(obj.ReferenceSignal)
                refSigPlotData=plot(ah,obj.ReferenceSignal.time,obj.ReferenceSignal.values,...
                'Color','#808080','LineWidth',2);
                legendPlots=[legendPlots,refSigPlotData];
                legendTitles{end+1}=obj.ReferenceSignal.name;
                fontSize=6.2;
            end

            userBlockValueFile=learning.assess.getAssessmentPlotLogFile();
            if exist(userBlockValueFile,'file')


                load(userBlockValueFile,'userStruct');
                blockHandleToPlot=obj.getBlockToPlot(userStruct,selectedBlockHandle);
                blockToPlot=get_param(blockHandleToPlot,'name');



                blockToPlot=obj.formatBlockName(blockToPlot);

                if isempty(blockToPlot)||~isprop(userStruct.simlog,blockToPlot)



                    lh=legend(requirementStr,'Location','southoutside','Orientation','horizontal','NumColumns',2);
                    lh.FontSize=fontSize;
                else
                    userBlockValueNode=userStruct.simlog.(blockToPlot).(obj.Value.name);
                    userBlockValue=userBlockValueNode.series.values;
                    userTimeSeries=userBlockValueNode.series.time;
                    userBlockValue=interp1(userTimeSeries,userBlockValue,obj.Value.time);
                    userPlotData=plot(ah,obj.Value.time,userBlockValue);
                    acceptableDifference=repmat(obj.minTolerance,length(obj.Value.values),1);
                    isSmallSignal=obj.Value.values.*obj.tolerance<=obj.minTolerance;
                    acceptableDifference(~isSmallSignal)=abs(obj.Value.values(~isSmallSignal)).*obj.tolerance;
                    incorrectValueIndex=abs(obj.Value.values-userBlockValue)>acceptableDifference;
                    incorrectDataHandle=plot(ah,obj.Value.time(incorrectValueIndex),userBlockValue(incorrectValueIndex),'r.','MarkerSize',10);

                    legendPlots=[legendPlots,userPlotData];
                    legendTitles{end+1}=signalStr;
                    if sum(incorrectValueIndex)>0
                        legendPlots=[legendPlots,incorrectDataHandle];
                        legendTitles{end+1}=incorrectStr;
                        fontSize=6.2;
                    end
                end


                answerHandle.Color(4)=0.7;
                if showFigureWindow
                    answerHandle.LineWidth=3;
                end
                userPlotData.Color=[0,0.4431,0.7373];
                userPlotData.LineWidth=1;
            end

            if showFigureWindow
                fontSize=12;
            end
            lh=legend(legendPlots,legendTitles,'Location','southoutside','Orientation','horizontal','NumColumns',2);
            lh.FontSize=fontSize;



            lh.Box='off';
            lh.Position=[0,0,1,.11];
            lh.ItemTokenSize=[15,18];
            ah.ClippingStyle='rectangle';
            ah.Box='on';
            ah.OuterPosition=[0,.11,1,.89];



            lineHandles=get(ah,'Children');
            isRefLine=~arrayfun(@(x)isequal(requirementStr,x.DisplayName)||isequal(signalStr,x.DisplayName)||isequal(incorrectStr,x.DisplayName),...
            lineHandles);
            if any(isRefLine)
                refLineHandle=lineHandles(isRefLine);
                lineHandles(isRefLine)=[];
                lineHandles(end+1)=refLineHandle;
                set(ah,'Children',lineHandles);
            end

            xlabel(message('learning:simulink:resources:SignalFigureXAxis').getString());
            if~isfield(obj.Value,'unit')||isempty(obj.Value.unit)
                unitString='';
            else
                unitString=[' (',obj.Value.unit,')'];
            end
            yLabel=[obj.Value.name,unitString];
            ylabel(yLabel);

            if~showFigureWindow
                currentTask=learning.simulink.Application.getInstance().getCurrentTask();
                figureSaveFolder=fullfile(tempdir,'signalCheck');
                if~exist(figureSaveFolder,'dir')
                    mkdir(figureSaveFolder);
                end
                figureSavePath=fullfile(figureSaveFolder,['task',num2str(currentTask),'.png']);
                saveas(fh,figureSavePath);
                close(fh);
            else
                fh.set('visible','on');
            end
        end

        function[fh,ah]=getFigureHandle(~,selectedBlockHandle,showFigureWindow)

            if isempty(selectedBlockHandle)
                blockName='';
            else
                blockName=get_param(selectedBlockHandle,'Name');
            end

            if showFigureWindow

                fh=findobj(0,'type','Figure','Tag',blockName);
                if~isempty(fh)

                    figure(fh);
                    delete(fh.Children);
                else
                    fh=figure;
                    fh.Tag=blockName;
                end
            else
                fh=figure('visible','off');
                fh.OuterPosition(3)=240;fh.OuterPosition(4)=230;
                fh.MenuBar='none';
                fh.PaperPositionMode='auto';
            end

            ah=axes(fh);
            if~showFigureWindow
                ah.FontSize=8;
            end

            fh.Name=blockName;
            fh.NumberTitle='off';
            fh.InvertHardcopy='off';
            fh.NextPlot='add';
        end
    end

    methods(Hidden,Access=protected)
        function validateInputProps(obj,props)


            [~,~,solutionFileExt]=fileparts(props.SolutionFile);
            hasAllProps=isequal(solutionFileExt,'.mat');

            obj.validateProps(props,hasAllProps);
        end

        function validateAssessProps(obj)
            hasAllProps=~isempty(obj.Value);

            obj.validateProps(obj,hasAllProps);
        end

        function validateProps(~,props,hasAllProps)
            hasAllProps=hasAllProps&&~isempty(props.BlockType);

            if~hasAllProps
                error(message('learning:simulink:resources:MissingParameters'));
            end
        end

        function[minFill,maxFill]=getFillBoundaries(~,time,minBound,maxBound)

            minFill.time=flipud(time)';
            minFill.values=flipud(minBound)';

            maxFill.time=time';
            maxFill.values=maxBound';
        end

        function blockToPlot=getBlockToPlot(obj,simStruct,selectedBlockHandle)







            userModelName=learning.simulink.Application.getInstance().getModelName();


            if~isempty(simStruct.correctBlock)&&...
                ~isempty(Simulink.findBlocks(userModelName,'Handle',simStruct.correctBlock))
                blockToPlot=simStruct.correctBlock;
                return;
            end


            if~isempty(selectedBlockHandle)&&...
                isequal(obj.BlockType,get_param(selectedBlockHandle,'BlockType'))&&...
                isequal(obj.ReferenceBlock,get_param(selectedBlockHandle,'ReferenceBlock'))
                blockToPlot=selectedBlockHandle;
                return;
            end




            matchingBlockTypes=find_system(userModelName,'FindAll','on',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'BlockType',obj.BlockType,...
            'ReferenceBlock',obj.ReferenceBlock);
            if~isempty(matchingBlockTypes)
                blockHandles=get_param(matchingBlockTypes,'handle');
                if~iscell(blockHandles)
                    blockHandles={blockHandles};
                end
                blockToPlot=blockHandles{1};
                return;
            end


            blockToPlot=[];
        end

        function formattedName=formatBlockName(~,blockName)



            formattedName=strrep(blockName,' ','_');
            formattedName=strrep(formattedName,newline,'_');
            formattedName=strrep(formattedName,'(','');
            formattedName=strrep(formattedName,')','');
        end
    end
end
