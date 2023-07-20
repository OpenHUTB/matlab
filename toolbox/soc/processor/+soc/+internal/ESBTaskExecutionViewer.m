classdef ESBTaskExecutionViewer<handle




    properties(SetAccess=private,GetAccess=public,Hidden)
ShowInSDI
SDIRunID
        SDISignalLabels={};
BuildDirectory
    end
    properties(SetAccess=private,GetAccess=public)
SignalSrcs
TaskViewers
CoreViewers
CoreViewerOffs
ModelName
DiagnosticsModelName
        IsRunInitialized=false;
        IsSignalsInitialized=false;
        IsCoresInitialized=false;
        IsRunning=false;
    end
    methods
        function h=ESBTaskExecutionViewer(varargin)
            h.TaskViewers=containers.Map;
            h.CoreViewers=containers.Map;
            h.CoreViewerOffs=containers.Map;
        end

        function initializeRun(h,showInSDI,mdlName)
            if h.IsRunInitialized,return;end
            h.IsRunInitialized=true;
            h.ShowInSDI=showInSDI;
            h.ModelName=mdlName;
            buildDirStruct=RTW.getBuildDir(h.ModelName);
            h.BuildDirectory=fullfile(buildDirStruct.CodeGenFolder,...
            buildDirStruct.ModelRefRelativeBuildDir);
            if~exist(h.BuildDirectory,'dir')
                mkdir(h.BuildDirectory);
            end
            Simulink.sdi.resetRunNamingRule();
            h.DiagnosticsModelName=[h.ModelName,...
            DAStudio.message('soc:scheduler:SimLoggingRunPostfix')];
        end

        function initializeSignals(h,saveToFile,runDir)
            if h.IsSignalsInitialized,return;end
            h.IsSignalsInitialized=true;
            reg=soc.internal.ESBRegistry.manageInstance(...
            'getfullmodelreferencehierarchy',h.ModelName);
            taskNames=arrayfun(@(x)x.Name,reg.Tasks,'UniformOutput',false);
            for taskIdx=1:numel(taskNames)
                taskName=taskNames{taskIdx};
                if~ismember(taskName,h.SDISignalLabels)
                    h.SDISignalLabels{end+1}=taskName;
                end
                if saveToFile
                    h.TaskViewers(taskName)=...
                    soc.profiler.ToAsyncQueueTaskView(...
                    h.ModelName,taskName,runDir,...
                    soc.profiler.TaskState.Ready,0);
                else
                    h.TaskViewers(taskName)=...
                    soc.profiler.ToAsyncQueueTaskView(...
                    h.ModelName,taskName,...
                    soc.profiler.TaskState.Ready,0);
                end
            end
        end

        function initializeCores(h,~)
            import codertarget.targethardware.*
            if h.IsCoresInitialized,return;end
            h.IsCoresInitialized=true;
            tm=soc.internal.connectivity.getTaskManagerBlock(h.ModelName,'all');
            if~iscell(tm),tm={tm};end
            offs=0;
            for procIdx=1:numel(tm)
                tmHandle=get_param(tm{procIdx},'Handle');
                rawTaskData=get_param(tm{procIdx},'allTaskData');
                allTaskData=soc.internal.TaskManagerData(rawTaskData,'evaluate',h.ModelName);
                myTaskNames=allTaskData.getTaskNames;
                taskData=allTaskData.getTask(myTaskNames);
                usedCores=arrayfun(@(x)(x.coreNum),taskData);

                thisEnv=getEnvironment(h.ModelName);
                idleState=DAStudio.message('soc:viewer:TaskNameNone');
                taskNames={idleState};

                myTaskNames=sort(myTaskNames);
                for taskIdx=1:numel(myTaskNames)
                    taskNames{end+1}=myTaskNames{taskIdx};%#ok<AGROW>
                end
                h.CoreViewerOffs(num2str(tmHandle))=offs;
                for coreIdx=0:thisEnv.NumCores-1
                    if~ismember(coreIdx,usedCores),continue;end
                    id=num2str(offs+coreIdx);
                    taskList=soc.profiler.TaskList(h.ModelName,...
                    taskNames,false);
                    refMdl=soc.internal.connectivity.getModelConnectedToTaskManager(getfullname(tmHandle));
                    if isequal(get_param(refMdl,'BlockType'),'ModelReference')
                        hCS=getActiveConfigSet(get_param(refMdl,'ModelName'));
                        pu=codertarget.targethardware.getProcessingUnitName(hCS);
                    else
                        pu='None';
                    end
                    if isequal(pu,'None')
                        coreLbl=DAStudio.message('soc:viewer:CoreLabel',coreIdx);
                    else
                        coreLbl=[pu,':Core',num2str(coreIdx)];
                    end
                    h.CoreViewers(id)=...
                    soc.profiler.ToAsyncQueueCoreView(...
                    h.ModelName,...
                    offs+coreIdx,...
                    taskList,...
                    0,coreLbl);
                end
                offs=offs+thisEnv.NumCores;
            end
        end


        function start(h)
            if h.IsRunning,return;end
            h.IsRunning=true;
            soc.profiler.startView(h.ModelName);
            hmiOpts.RecordOn=1;
            hmiOpts.VisualizeOn=1;
            hmiOpts.CommandLine=false;
            hmiOpts.StartTime=get_param(h.ModelName,'SimulationTime');
            hmiOpts.StopTime=inf;
            hmiOpts.EnableRollback=slprivate('onoff',...
            get_param(h.ModelName,'EnableRollback'));
            hmiOpts.SnapshotInterval=get_param(h.ModelName,...
            'SnapshotInterval');
            hmiOpts.NumberOfSteps=get_param(h.ModelName,'NumberOfSteps');
            Simulink.HMI.slhmi('sim_start',h.ModelName,hmiOpts);
        end

        function updateTaskLog(h,taskName,stateChangeTime,state)
            hView=h.TaskViewers(taskName);
            hView.update(state,int64(stateChangeTime*1e9));
        end

        function updateCoreLog(h,taskMgr,coreIdx,time,taskIdx)
            tmHandle=get_param(taskMgr,'Handle');
            offs=h.CoreViewerOffs(num2str(tmHandle));
            id=num2str(offs+coreIdx);
            hView=h.CoreViewers(id);
            hView.update(taskIdx,time*1e9);
        end

        function clear(h)
            h.IsRunInitialized=false;
            h.IsSignalsInitialized=false;
            h.IsCoresInitialized=false;
            if h.IsRunning
                keys=h.TaskViewers.keys;
                for i=1:numel(keys)
                    viewObj=h.TaskViewers(keys{i});
                    viewObj.clear;
                end
                keys=h.CoreViewers.keys;
                for i=1:numel(keys)
                    viewObj=h.CoreViewers(keys{i});
                    viewObj.clear;
                end
            end
            h.IsRunning=false;
        end
    end
end
