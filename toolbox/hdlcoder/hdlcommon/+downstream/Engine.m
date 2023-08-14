


classdef Engine<handle





    properties

        CurrentStage=0;
        sidx=0;
        StageIDList='';
        msgMap=[];
    end

    properties(Access=protected,Hidden=true)

        hToolDriver=0;
    end

    methods

        function obj=Engine(hToolDriver)


            obj.hToolDriver=hToolDriver;


            obj.StageIDList={'Start','CreateProject'};
            obj.sidx=enum(obj.StageIDList,0);


            obj.CurrentStage=obj.sidx.Start;


            msgKeys={'CreateProject',...
            'Synthesis',...
            'Synthesis->PostMapTiming',...
            'Map->PostMapTiming',...
            'PAR->PostPARTiming',...
            'Implementation->PostPARTiming',...
            'ProgrammingFile'};

            msgVals={'HDLShared:hdldialog:HDLWACreateProject',...
            'HDLShared:hdldialog:HDLWAPerformLogicSynthesis',...
            'HDLShared:hdldialog:HDLWAVivadoSynthesis',...
            'HDLShared:hdldialog:HDLWAPerformMapping',...
            'HDLShared:hdldialog:HDLWAPerformPlaceAndRoute',...
            'HDLShared:hdldialog:HDLWAVivadoImplementation',...
            'HDLShared:hdldialog:HDLWAProgramTargetDevice'};

            obj.msgMap=containers.Map(msgKeys,msgVals);
        end

        function initialize(obj,workflowIDList)


            obj.StageIDList=[{'Start','CreateProject'},workflowIDList];
            obj.sidx=enum(obj.StageIDList,0);


            obj.CurrentStage=obj.sidx.Start;
        end

        function[status,result]=run(obj,varargin)

            if nargin==2
                stageID=varargin{1};
                if isempty(stageID)
                    obj.printHelpMessage
                    return;
                end
                if~iscell(stageID)
                    stageID={stageID};
                end
                for ii=1:length(stageID)
                    if~ischar(stageID{ii})||~any(strcmp(stageID{ii},obj.StageIDList))
                        obj.printHelpMessage
                        return;
                    end
                end
                [status,result]=obj.runStage(stageID);
            else
                obj.printHelpMessage;
            end
        end

        function engineDisp(obj,varargin)

            fprintf('   CurrentStatus : ');
            if nargin==2&&ischar(varargin{1})
                fprintf('%s\n',varargin{1});
            else
                fprintf('%s\n',obj.showCurrentStatus(obj.CurrentStage));
            end
            fprintf('\n');

            if obj.CurrentStage==obj.sidx.Start
                fprintf('   ''%s''',obj.getStageID(obj.sidx.Start));
            else
                fprintf('   %s',obj.getStageID(obj.sidx.Start));
            end

            for ii=1:length(obj.StageIDList)-1
                if obj.CurrentStage<ii
                    fprintf(' -> <a href="matlab:downstream.handle(''Model'',''%s'').run(''%s'');">%s</a>',obj.hToolDriver.hD.hCodeGen.ModelName,obj.getStageID(ii),obj.getStageID(ii));
                elseif obj.CurrentStage==ii
                    fprintf(' -> ''%s''',obj.getStageID(ii));
                else
                    fprintf(' -> %s',obj.getStageID(ii));
                end
            end
            fprintf('\n\n');
        end

        function stageIDList=getStageID(obj,stageIdx)
            stageIDList=obj.StageIDList{stageIdx+1};
        end

        function setCurrentStage(obj,workflowID)
            stageIdx=obj.sidx.(workflowID);
            obj.CurrentStage=stageIdx;
        end

        function resetCurrentStage(obj)
            obj.CurrentStage=obj.sidx.Start;
        end

    end

    methods(Access=protected)

        function[status,result]=runStage(obj,TargetStage)













            targetLen=length(TargetStage);
            targetIdx=cell(1,targetLen);
            for ii=1:targetLen
                targetIdx{ii}=obj.sidx.(TargetStage{ii});
                if ii>1
                    tDif=targetIdx{ii}-targetIdx{ii-1};
                    if tDif~=1


                        obj.printHelpMessage;
                    end
                end
            end



            if obj.CurrentStage==obj.sidx.Start&&...
                targetIdx{1}>=obj.sidx.CreateProject&&...
                isempty(obj.hToolDriver.hD.hCodeGen.TimeStamp)
                obj.hToolDriver.attachCodeGenInfo;
            end


            if obj.hToolDriver.hD.hCodeGen.isNewCodeGen
                obj.hToolDriver.attachCodeGenInfo;
                obj.CurrentStage=obj.sidx.Start;
            end

            if~obj.hToolDriver.hD.isMLHDLC&&hdlwfsmartbuild.isSmartbuildOn(obj.hToolDriver.hD.isMLHDLC,obj.hToolDriver.hD.hCodeGen.ModelName)&&(obj.hToolDriver.hD.isGenericWorkflow||obj.hToolDriver.hD.isTurnkeyWorkflow||obj.hToolDriver.hD.isXPCWorkflow)

                rebuildDecision=1;
                needSmartbuild=0;
                hDI=obj.hToolDriver.hD;
                if(numel(TargetStage)==1)&&(strcmp(TargetStage{1},'CreateProject'))
                    smartBuildObj=hdlwfsmartbuild.CreatePrjSb.getInstance(hDI);
                    rebuildDecision=smartBuildObj.preprocess;
                    needSmartbuild=1;
                elseif~strcmpi(obj.hToolDriver.hD.getToolName(),'xilinx vivado')&&(numel(TargetStage)==1)&&(strcmp(TargetStage{1},'Synthesis'))
                    smartBuildObj=hdlwfsmartbuild.LogicSynthesisSb.getInstance(hDI);
                    rebuildDecision=smartBuildObj.preprocess;
                    needSmartbuild=1;
                elseif strcmpi(obj.hToolDriver.hD.getToolName(),'xilinx vivado')&&(numel(TargetStage)==1)&&(strcmp(TargetStage{1},'Synthesis'))
                    smartBuildObj=hdlwfsmartbuild.VivadoSynthesisSb.getInstance(hDI);
                    rebuildDecision=smartBuildObj.preprocess;
                    needSmartbuild=1;
                elseif(numel(TargetStage)==2)&&(strcmp(TargetStage{1},'Map'))&&(strcmp(TargetStage{2},'PostMapTiming'))
                    smartBuildObj=hdlwfsmartbuild.MappingSb.getInstance(hDI);
                    rebuildDecision=smartBuildObj.preprocess;
                    needSmartbuild=1;
                elseif(numel(TargetStage)==2)&&(strcmp(TargetStage{1},'Synthesis'))&&(strcmp(TargetStage{2},'PostMapTiming'))
                    smartBuildObj=hdlwfsmartbuild.VivadoSynthesisSb.getInstance(hDI);
                    rebuildDecision=smartBuildObj.preprocess;
                    needSmartbuild=1;
                elseif(numel(TargetStage)==2)&&(strcmp(TargetStage{1},'PAR'))&&(strcmp(TargetStage{2},'PostPARTiming'))
                    smartBuildObj=hdlwfsmartbuild.PaRSb.getInstance(hDI);
                    rebuildDecision=smartBuildObj.preprocess;
                    needSmartbuild=1;
                elseif(numel(TargetStage)==2)&&(strcmp(TargetStage{1},'Implementation'))&&(strcmp(TargetStage{2},'PostPARTiming'))
                    smartBuildObj=hdlwfsmartbuild.ImplementationSb.getInstance(hDI);
                    rebuildDecision=smartBuildObj.preprocess;
                    needSmartbuild=1;
                elseif(numel(TargetStage)==1)&&(strcmp(TargetStage{1},'ProgrammingFile'))
                    smartBuildObj=hdlwfsmartbuild.GenProgrammingFileSb.getInstance(hDI);
                    rebuildDecision=smartBuildObj.preprocess;
                    needSmartbuild=1;
                end

                if needSmartbuild
                    if rebuildDecision
                        [status,result]=obj.runStageCore(targetIdx,targetLen,TargetStage);
                        if status
                            smartBuildObj.postprocessRebuild(result);
                        end
                    else
                        [status,result]=smartBuildObj.postprocessSkip;
                    end
                else
                    [status,result]=obj.runStageCore(targetIdx,targetLen,TargetStage);
                end
            else
                [status,result]=obj.runStageCore(targetIdx,targetLen,TargetStage);
            end

        end

        function[status,result]=runStageCore(obj,targetIdx,targetLen,TargetStage)

            currentIdx=obj.CurrentStage;


            if targetIdx{1}>currentIdx
                runStageIdx=(currentIdx+1):targetIdx{end};
            else
                runStageIdx=targetIdx{1}:targetIdx{end};
            end




            if runStageIdx(1)==obj.sidx.CreateProject
                obj.runPreCreateProjectProcess;
                obj.hToolDriver.hEmitter.updateCreateProjectTcl;
                obj.hToolDriver.hTool.lockCurrentDir;


                if obj.hToolDriver.hD.cmdDisplay&&obj.hToolDriver.hTool.UnSupportedVersion
                    warning(message('hdlcommon:workflow:UnsupportedVersionNumber',obj.hToolDriver.hTool.VersionWarningMsg));
                end
            end


            obj.hToolDriver.hEmitter.generateTcl(runStageIdx);


            systemStatus1=0;
            resultStr1='';
            systemStatus2=0;
            resultStr2='';
            if~obj.hToolDriver.hD.tclOnly
                [systemStatus1,resultStr1]=obj.hToolDriver.hTool.runTclFile(obj.hToolDriver.hEmitter.TclFileName);



                if~systemStatus1

                    captureError=obj.hToolDriver.hTool.cmd_captureError;
                    if~isempty(captureError)
                        logStr=resultStr1;%#ok<NASGU>
                        for ii=1:length(captureError)
                            cmdCapture=captureError{ii};
                            cmdStr=sprintf('regexp(logStr, ''%s'', ''once'')',cmdCapture);
                            cmdResult=eval(cmdStr);
                            if~isempty(cmdResult)

                                systemStatus1=1;
                                break;
                            end
                        end
                    end
                end


                if~isempty(obj.hToolDriver.hTool.CustomTclFile)&&...
                    length(runStageIdx)==1&&runStageIdx(1)==obj.sidx.CreateProject
                    obj.hToolDriver.hEmitter.generateCustomTcl;
                    [systemStatus2,resultStr2]=obj.hToolDriver.hTool.runTclFile(obj.hToolDriver.hEmitter.CustomTclFileName);
                end
            end


            if targetLen>1
                taskName=sprintf('%s->%s',TargetStage{1},TargetStage{end});
            else
                taskName=sprintf('%s',TargetStage{1});
            end





            if(obj.msgMap.isKey(taskName))
                fileName=message([obj.msgMap(taskName),'ENGLISH']).getString;
                taskName=message(obj.msgMap(taskName)).getString;
            else
                fileName=taskName;
            end


            status=~(systemStatus1||systemStatus2);


            if(status)
                if(strcmp(TargetStage{1},'CreateProject'))
                    [tool,link]=obj.hToolDriver.hD.getProjectToolLink;
                    msg=message('hdlcoder:workflow:GeneratingProject',tool,link);
                    if(obj.hToolDriver.hD.cmdDisplay)
                        hdldisp(msg);
                    end
                end

                obj.CurrentStage=targetIdx{end};

            end


            resultStr=sprintf('%s%s',resultStr1,resultStr2);

            result=obj.hToolDriver.hD.logDisplayToolResult(status,resultStr,taskName,fileName);


            if obj.hToolDriver.hD.cmdDisplay

                hdldisp(resultStr);
            end

        end

        function printHelpMessage(obj)

            estr=sprintf('Downstream Integration: Please specify the target Workflow Stage as input.\n');
            estr=sprintf('%sExample: handle.run(''%s'')\n',estr,obj.StageIDList{end});

            estr=sprintf('%sList of supported %s tool workflow stages are:\n',estr,obj.hToolDriver.hTool.ToolName);
            for ii=2:length(obj.StageIDList)
                estr=sprintf('%srun(''%s'')\n',estr,obj.StageIDList{ii});
            end
            error(message('hdlcommon:workflow:WrongWorkflowStage',estr));
        end

        function status=showCurrentStatus(obj,stageID)

            if stageID==obj.sidx.Start
                status=sprintf('Initialization Done');
            elseif stageID<length(obj.StageIDList)
                status=sprintf('%s Done',obj.getStageID(stageID));
            else
                error(message('hdlcommon:workflow:InvalidStageID'));
            end
        end

        function runPreCreateProjectProcess(obj)




            if downstream.plugin.PluginBase.existPluginFile(...
                obj.hToolDriver.hTool.PluginPath,'process_preCreateProject')
                cmdStr=sprintf('%s.%s',obj.hToolDriver.hTool.PluginPackage,'process_preCreateProject(obj.hToolDriver)');
                try
                    eval(cmdStr);
                catch me
                    rethrow(me);
                end
            end



            isTargetGeneric=obj.hToolDriver.hD.isGenericWorkflow;
            if~isTargetGeneric
                if downstream.plugin.PluginBase.existPluginFile(...
                    obj.hToolDriver.hD.hTurnkey.hBoard.PluginPath,'process_preCreateProject')
                    cmdStr=sprintf('%s.%s',obj.hToolDriver.hD.hTurnkey.hBoard.PluginPackage,'process_preCreateProject(obj.hToolDriver)');
                    try
                        eval(cmdStr);
                    catch me
                        rethrow(me);
                    end
                end
                if any(strcmpi(obj.hToolDriver.hD.hTurnkey.hBoard.FPGAFamily,{'kintex7','virtex7'}))
                    hWorkflow=obj.hToolDriver.hD.getWorkflow('ProgrammingFile');
                    hWorkflow.TclTemplate=[...
                    {'project set "Other Bitgen Command Line Options" "-g UnconstrainedPins:Allow" -process "Generate Programming File"'},...
                    hWorkflow.TclTemplate];
                end
            end
        end

    end

end


function syms=enum(names,first)











    base=1;
    if nargin==2
        base=first;
    end

    syms=struct;
    for j=1:numel(names)
        n=names{j};
        syms.(n)=int16(base+j-1);
    end
end



