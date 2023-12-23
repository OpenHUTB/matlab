classdef MultithreadingAnalysis<handle

    properties
SubsystemHandle
TopModelHandle
ModelRefPaths
AppHandle

Listeners
SimMetaDataCallback

SimProgressTimer

DataflowUI

        IsPartitioning=false
        CompileSuccess=true
        SimSuccess=true
SimulinkStage
CachedLatencyValue
ProgressState
AnalysisStage
        StopTimeVal=1;
        IsInfProfile=false
        IsBuilding=false
SimMetaData
InfoCache
        ClosingUI=false
        SimModeValid=true
        MovingProgressPosition=0

        ModelSettings={...
        'SimCompilerOptimization','on',false;...
        'SimCtrlC','off',false;...
        'IntegerOverflowMsg','none',false;...
        'IntegerSaturationMsg','none',false};

        ModelSettingsChanged=false
    end



    methods
        function obj=MultithreadingAnalysis(subsystem)
            obj.SubsystemHandle=get_param(subsystem,'Handle');
            [obj.TopModelHandle,obj.ModelRefPaths]=getTopModel(obj.SubsystemHandle);
            obj.ProgressState=dfs.analysis.ProgressTrackerState;
            obj.AnalysisStage=dfs.analysis.AnalysisStageEnum.NotAnalyzing;
            obj.AppHandle=dfs.analysis.MultithreadingAnalysisDDG(obj.SubsystemHandle,obj.TopModelHandle,obj.ModelRefPaths,getDefaultDialogData(obj));
            dialog=DAStudio.Dialog(obj.AppHandle);
            show(obj.AppHandle,dialog);
            createListeners(obj);
            updateDialog(obj);
        end

        function delete(obj)
            obj.ClosingUI=true;
            clear(obj);
            removeSelfFromCache(obj);
            closeDialog(obj.AppHandle);
        end

        function clear(obj)
            clearSimulinkStage(obj);
            clearListeners(obj);
        end

        function updateDialog(obj)
            d=getDialogData(obj);

            if isvalid(obj)
                refreshDialog(obj.AppHandle,d);
            end
        end

        function open(obj)
            updateDialog(obj);
            setFocus(obj.AppHandle);
        end

        function refreshData(obj)
            obj.IsPartitioning=false;
            obj.IsInfProfile=false;
            obj.SimSuccess=true;
            obj.ModelSettingsChanged=false;

            oc=onCleanup(@()clearAnalysisStageIfNotProfiling(obj));
            ud=onCleanup(@()updateDialog(obj));

            obj.AnalysisStage=dfs.analysis.AnalysisStageEnum.InitalUpdate;

            updateDialog(obj);

            modelName=getfullname(obj.TopModelHandle);

            stageName=getString(message('dataflow:MultithreadingAnalysis:DiagnosticViewerRefreshData'));
            obj.SimulinkStage=sldiagviewer.createStage(stageName,'ModelName',modelName);


            simMode=get_param(obj.TopModelHandle,'SimulationMode');
            obj.SimModeValid=strcmpi(simMode,'normal')||...
            strcmpi(simMode,'accelerator')||...
            strcmpi(simMode,'rapid-accelerator');

            if~obj.SimModeValid
                clearSimulinkStage(obj);
                return;
            end

            try
                if~strcmpi(simMode,'rapid-accelerator')
                    set_param(obj.TopModelHandle,'SimulationCommand','update');
                else
                    Simulink.BlockDiagram.buildRapidAcceleratorTarget(obj.TopModelHandle);
                end
            catch E
                sldiagviewer.reportError(E);
                clearSimulinkStage(obj);
                return
            end

            state=dfs.analysis.MultithreadingState.getSubsystemState(obj.SubsystemHandle,obj.TopModelHandle,false);

            if state==dfs.analysis.MultithreadingState.NewParent
                reparent(obj);
                updateDialog(obj);
                state=dfs.analysis.MultithreadingState.getSubsystemState(obj.SubsystemHandle,obj.TopModelHandle,false);
            end

            if state==dfs.analysis.MultithreadingState.NeedsAutotuning




                stopTime=evalStopTime(obj);
                if isinf(stopTime)
                    obj.IsInfProfile=true;
                    obj.StopTimeVal=1;
                    clearAnalysisStage(obj);
                    updateDialog(obj);
                    return;
                end
                obj.StopTimeVal=stopTime;
                if(obj.StopTimeVal==0)
                    obj.StopTimeVal=1;
                end

                try
                    obj.AnalysisStage=dfs.analysis.AnalysisStageEnum.ProfilingSimulation;
                    set_param(obj.TopModelHandle,'SimulationCommand','start');
                catch E
                    sldiagviewer.reportError(E);
                    clearSimulinkStage(obj);
                end
            else

                refreshDataPhaseTwo(obj);
            end
        end

        function refreshDataPhaseTwo(obj)

            refreshDataPhaseTwoImpl(obj);
            open(obj);
        end

        function refreshDataPhaseTwoImpl(obj)
            oc=onCleanup(@()clearAnalysisStage(obj));
            cs=onCleanup(@()clearSimulinkStage(obj));
            ud=onCleanup(@()updateDialog(obj));


            if~(obj.CompileSuccess&&obj.SimSuccess)
                return;
            end

            state=dfs.analysis.MultithreadingState.getSubsystemState(obj.SubsystemHandle,obj.TopModelHandle,false);






            if(obj.TopModelHandle~=get_param(bdroot(obj.SubsystemHandle),'handle'))
                state=dfs.analysis.MultithreadingState.ProfiledNoSchedule;
            end


            if state==dfs.analysis.MultithreadingState.ProfiledNoSchedule
                try
                    obj.AnalysisStage=dfs.analysis.AnalysisStageEnum.PostProfileUpdate;

                    if~strcmpi(get_param(obj.TopModelHandle,'SimulationMode'),'rapid-accelerator')
                        set_param(obj.TopModelHandle,'SimulationCommand','update');
                    else
                        Simulink.BlockDiagram.buildRapidAcceleratorTarget(obj.TopModelHandle);
                    end
                catch E
                    sldiagviewer.reportError(E);
                    return;
                end
            end
        end
    end

    methods(Access=private)
        function removeSelfFromCache(obj)
            cache=dfs.analysis.InstanceCache.getInstance();
            remove(cache,obj.SubsystemHandle);
        end

        function createListeners(obj)
            modelHandle=bdroot(obj.SubsystemHandle);
            dispatcher=DAStudio.EventDispatcher;
            topModelObject=get_param(obj.TopModelHandle,'Object');
            modelObject=get_param(modelHandle,'Object');
            subsystemObject=get_param(obj.SubsystemHandle,'Object');
            ui=getDataflowUI(obj);


            obj.Listeners{end+1}=handle.listener(dispatcher,'SimStatusChangedEvent',@(s,e)simStatusChanged(obj,e));

            obj.Listeners{end+1}=handle.listener(dispatcher,'PropertyChangedEvent',@(s,e)propertyChanged(obj,e));

            obj.Listeners{end+1}=Simulink.listener(modelObject,'CloseEvent',@(src,event)delete(obj));

            obj.Listeners{end+1}=Simulink.listener(topModelObject,'EngineCompPassed',@(src,event)compileSuccess(obj));

            obj.Listeners{end+1}=Simulink.listener(topModelObject,'EngineCompFailed',@(src,event)compileFailed(obj));

            obj.Listeners{end+1}=Simulink.listener(topModelObject,'EnginePreCompStart',@(src,event)simulationBegin(obj));

            obj.Listeners{end+1}=Simulink.listener(topModelObject,'EngineSimulationEnd',@(src,event)simulationEnd(obj));

            obj.Listeners{end+1}=Simulink.listener(subsystemObject,'DeleteEvent',@(src,event)deleteEvent(obj));

            obj.Listeners{end+1}=Simulink.listener(subsystemObject,'NameChangeEvent',@(src,event)nameChangedEvent(obj));

            for i=1:size(obj.ModelSettings,1)
                obj.Listeners{end+1}=configset.ParamListener(obj.TopModelHandle,obj.ModelSettings{i,1},@obj.configsetChangeEvent);
            end

            if~isempty(ui)
                obj.Listeners{end+1}=addlistener(ui,'PartitioningEvent',@(src,event)partitioningEvent(obj));
            end

            createMetaDataCallback(obj);
        end

        function ui=getDataflowUI(obj)
            ui=obj.DataflowUI;
            if isempty(ui)
                model=bdroot(obj.SubsystemHandle);
                ui=get_param(model,'DataflowUI');
                obj.DataflowUI=ui;
            end
        end

        function compileSuccess(obj)
            if isvalid(obj)
                obj.CompileSuccess=true;
            end
        end

        function compileFailed(obj)
            if isvalid(obj)
                obj.CompileSuccess=false;
            end
        end

        function simStatusChanged(obj,e)
            if~isvalid(obj)
                return
            end

            if isa(e,'EventStringData')&&isa(e.Source,'Simulink.BlockDiagram')
                if strcmp(getFullName(e.Source),getfullname(obj.TopModelHandle))







                    updateDialog(obj);
                end
            end
        end

        function simulationBegin(obj)

            if~isvalid(obj)||obj.ClosingUI
                return;
            end
            if obj.AnalysisStage==dfs.analysis.AnalysisStageEnum.NotAnalyzing
                obj.CompileSuccess=true;
                obj.SimSuccess=true;
                obj.IsInfProfile=false;
                obj.IsBuilding=false;
            end
        end

        function simulationEnd(obj)

            if~isvalid(obj)||obj.ClosingUI
                return;
            end
            clearSimProgressTimer(obj);
            if obj.AnalysisStage==dfs.analysis.AnalysisStageEnum.ProfilingSimulation

                assert(~isempty(obj.SimMetaData),'Sim meta data is empty');
                obj.SimSuccess=isempty(obj.SimMetaData.ExecutionInfo.ErrorDiagnostic);
                refreshDataPhaseTwo(obj);
            else
                updateDialog(obj);
            end
        end

        function startSimProgressTimer(obj)
            if isempty(obj.SimProgressTimer)
                obj.SimProgressTimer=timer('ExecutionMode','fixedSpacing',...
                'BusyMode','drop',...
                'StartDelay',1,...
                'Period',1,...
                'ObjectVisibility','off',...
                'TimerFcn',@(t,e)simProgressUpdate(obj));
                obj.MovingProgressPosition=10;
                start(obj.SimProgressTimer);
            end
        end

        function simProgressUpdate(obj)

            if~isvalid(obj)||obj.ClosingUI
                return;
            end
            updateDialog(obj);
        end

        function clearSimProgressTimer(obj)
            if~isempty(obj.SimProgressTimer)&&isvalid(obj.SimProgressTimer)
                stop(obj.SimProgressTimer);
                delete(obj.SimProgressTimer);
                obj.SimProgressTimer=[];
            end
        end

        function propertyChanged(obj,e)
            if isa(e,'EventStringData')&&strcmp(e.Type,'PropertyChangedEvent')
                if isa(e.Source,'Simulink.BlockDiagram')&&(e.Source==get_param(obj.TopModelHandle,'Object'))

                    isBuilding=strcmp(get_param(obj.TopModelHandle,'BuildInProgress'),"on");
                    if isBuilding~=obj.IsBuilding
                        obj.IsBuilding=isBuilding;
                        updateDialog(obj);
                    end
                elseif isa(e.Source,'Simulink.SubSystem')&&(e.Source==get_param(obj.SubsystemHandle,'Object'))

                    updateDialog(obj);
                end
            end
        end

        function deleteEvent(obj)
            clear(obj);
            delete(obj);
        end

        function nameChangedEvent(obj)
            updateDialog(obj);
        end

        function partitioningEvent(obj)
            if isvalid(obj)
                ui=getDataflowUI(obj);
                if~isempty(ui)
                    obj.IsPartitioning=(ui.PartitioningProgress<100)&&(~ui.NeedsProfiling);
                end
                updateDialog(obj);
            end
        end

        function configsetChangeEvent(obj,~,~,~)
            obj.ModelSettingsChanged=true;
            updateDialog(obj);
        end

        function createMetaDataCallback(obj)
            subsystemName=getfullname(obj.SubsystemHandle);
            obj.SimMetaDataCallback=['DSA_CALLBACK_',subsystemName];
            slInternal('registerSimMetadataCallback',...
            obj.SimMetaDataCallback,...
            @(mData)obj.metaDataEvent(mData));
        end

        function clearMetaDataCallback(obj)
            slInternal(...
            'unRegisterSimMetadataCallback',...
            obj.SimMetaDataCallback);
        end

        function metaDataEvent(obj,mData)

            if strcmp(mData.ModelInfo.ModelName,getfullname(obj.TopModelHandle))
                obj.SimMetaData=mData;
            end
        end

        function clearAnalysisStage(obj)
            obj.AnalysisStage=dfs.analysis.AnalysisStageEnum.NotAnalyzing;
        end

        function clearAnalysisStageIfNotProfiling(obj)
            if isvalid(obj)&&~(obj.AnalysisStage==dfs.analysis.AnalysisStageEnum.ProfilingSimulation)
                clearAnalysisStage(obj);
            end
        end

        function clearSimulinkStage(obj)
            if isvalid(obj)
                obj.SimulinkStage=[];
            end
        end

        function clearListeners(obj)
            if~isvalid(obj)
                return;
            end

            for i=1:numel(obj.Listeners)
                delete(obj.Listeners{i});
                obj.Listeners{i}=[];
            end

            clearMetaDataCallback(obj);
        end

        function data=getDefaultDialogData(obj)
            data.ValidData=false;
            data.SuggestedLatency=0;
            data.SuggestedLatencyStr='';
            data.CurrentLatency=0;
            data.CurrentLatencyStr='';
            data.ThreadsStr='';
            data.TallPoleBlock='';
            data.TallPoleRatio=0;
            data.Message='';
            data.ShowDiagnosticViewerErrorLink=false;
            data.ShowDiagnosticViewerWarningLink=false;
            data.ShowStopSimulationLink=false;
            data.ModelIsStopped=strcmp(get_param(obj.TopModelHandle,'SimulationStatus'),'stopped');
            data.ProgressState=obj.ProgressState;
            data.TimeStamp='';
            data.AnalysisStage=obj.AnalysisStage;

            data.MultithreadingAnalysis=obj;
            data.OptimalModelSettings.AllOptimal=false;
            data.OptimalModelSettings.Params=obj.ModelSettings;
        end

        function data=getDialogData(obj)

            import dfs.analysis.ProgressTrackerEnum;

            data=getDefaultDialogData(obj);
            data=getModelSettings(obj,data);


            simMode=get_param(obj.TopModelHandle,'SimulationMode');
            isRapidAccel=strcmpi(simMode,'rapid-accelerator')||...
            (strcmpi(simMode,'external')&&...
            ~strcmpi(get_param(obj.TopModelHandle,'RapidAcceleratorSimStatus'),'inactive'));

            if~obj.SimModeValid
                data.Message=getString(message('dataflow:MultithreadingAnalysis:UnsupportedSimMode'));
                data.ProgressState.setRuntimeProgress(ProgressTrackerEnum.Error,ProgressTrackerEnum.None,0,ProgressTrackerEnum.None,0);
                return
            end

            if~obj.CompileSuccess
                data.Message=getString(message('dataflow:MultithreadingAnalysis:CheckError'));
                data.ShowDiagnosticViewerErrorLink=true;
                data.ProgressState.setRuntimeProgress(ProgressTrackerEnum.Error,ProgressTrackerEnum.None,0,ProgressTrackerEnum.None,0);
                return
            end

            if~obj.SimSuccess
                data.Message=getString(message('dataflow:MultithreadingAnalysis:ProfileSimError'));
                data.ShowDiagnosticViewerErrorLink=true;
                data.ProgressState.setRuntimeProgress(ProgressTrackerEnum.Complete,ProgressTrackerEnum.Error,0,ProgressTrackerEnum.None,0);
                return
            end

            if obj.IsInfProfile
                data.Message=getString(message('dataflow:MultithreadingAnalysis:InfProfileError'));
                data.ProgressState.setRuntimeProgress(ProgressTrackerEnum.Complete,ProgressTrackerEnum.Error,0,ProgressTrackerEnum.None,0);
                return
            end

            if obj.IsBuilding&&~isRapidAccel
                data.Message=getString(message('dataflow:MultithreadingAnalysis:SimulinkBusy'));
                data.ProgressState.setRuntimeProgress(ProgressTrackerEnum.None,ProgressTrackerEnum.None,0,ProgressTrackerEnum.None,0);
                data.ModelIsStopped=false;
                return
            end


            if~isRapidAccel
                simStatus=get_param(obj.TopModelHandle,'SimulationStatus');
            else
                simStatus=get_param(obj.TopModelHandle,'RapidAcceleratorSimStatus');
            end

            if obj.AnalysisStage~=dfs.analysis.AnalysisStageEnum.NotAnalyzing


                data.ShowStopSimulationLink=strcmpi(simStatus,'running');






                if(obj.IsPartitioning)


                    ui=getDataflowUI(obj);
                    if ui.NeedsProfiling


                        data.ProgressState.clearProgress();
                    elseif ui.isSingleThread(obj.SubsystemHandle)
                        data.ProgressState.setEditTimeProgress(dfs.analysis.MultithreadingState.SingleThread);
                    else
                        data.Message=getString(message('dataflow:MultithreadingAnalysis:Partitioning'));

                        if ui.PartitioningProgress>=100
                            obj.IsPartitioning=false;
                            data.ProgressState.setRuntimeProgress(ProgressTrackerState.Complete,ProgressTrackerState.Complete,110,ProgressTrackerState.Complete,110);
                        else
                            partProgress=ui.PartitioningProgress+10;
                            data.ProgressState.setRuntimeProgress(ProgressTrackerEnum.Complete,ProgressTrackerEnum.Complete,110,ProgressTrackerEnum.None,partProgress);
                        end
                    end
                    return;
                end

                if~isRapidAccel



                    if strcmp(simStatus,'initializing')
                        data.Message=getString(message('dataflow:MultithreadingAnalysis:InitializingModel'));
                        data.ProgressState.setRuntimeProgress(ProgressTrackerEnum.Complete,ProgressTrackerEnum.None,10,ProgressTrackerEnum.None,0);
                        return;
                    end


                    if strcmp(simStatus,'updating')
                        data.Message=getString(message('dataflow:MultithreadingAnalysis:UpdatingModel'));
                        return;
                    end


                    if strcmpi(simStatus,'running')||strcmp(simStatus,'paused')


                        startSimProgressTimer(obj);
                        simTime=get_param(obj.TopModelHandle,'SimulationTime');


                        profileProgress=(simTime/obj.StopTimeVal)*100;
                        profileProgress=round(profileProgress);
                        data.Message=getString(message('dataflow:MultithreadingAnalysis:Profiling',profileProgress));
                        data.ProgressState.setRuntimeProgress(ProgressTrackerEnum.Complete,ProgressTrackerEnum.None,profileProgress+10,ProgressTrackerEnum.None,0);
                        return;
                    end
                else



                    if strcmpi(simStatus,'running')||strcmp(simStatus,'connecting')

                        startSimProgressTimer(obj);
                        data.Message=getString(message('dataflow:MultithreadingAnalysis:ProfilingRapidAccel'));
                        data.ProgressState.setProfilingProgressIndeterminate(obj.MovingProgressPosition,obj.MovingProgressPosition+10);
                        obj.MovingProgressPosition=mod(obj.MovingProgressPosition+20,100);
                        return;
                    end
                end



                data.Message=getString(message('dataflow:MultithreadingAnalysis:CollectingData'));
                return
            else

                if(~isRapidAccel&&~strcmp(simStatus,'stopped'))||...
                    (isRapidAccel&&~strcmp(simStatus,'inactive'))

                    ui=getDataflowUI(obj);
                    topMostDataflowSubsystem=ui.getTopMostDataflowSubsystem(obj.SubsystemHandle);
                    if topMostDataflowSubsystem==0
                        removeSelfFromCache(obj);
                    end
                    if topMostDataflowSubsystem~=obj.SubsystemHandle
                        reparent(obj);
                        data=getDialogData(obj);
                    end
                    data.Message=getString(message('dataflow:MultithreadingAnalysis:SimulinkBusy'));


                    if numel(obj.InfoCache)==3
                        data.SuggestedLatencyStr=obj.InfoCache{1};
                        data.CurrentLatencyStr=obj.InfoCache{2};
                        data.ThreadsStr=obj.InfoCache{3};
                    end
                    return;
                end
            end



            obj.IsPartitioning=false;
            state=dfs.analysis.MultithreadingState.getSubsystemState(obj.SubsystemHandle,obj.TopModelHandle,obj.ModelSettingsChanged);
            data.ProgressState.setEditTimeProgress(state);

            switch state
            case dfs.analysis.MultithreadingState.NoDataForModel
                data=addMessage(data,'dataflow:MultithreadingAnalysis:Analyze');
            case dfs.analysis.MultithreadingState.NoDataForSubsystem
                data=addMessage(data,'dataflow:MultithreadingAnalysis:Analyze');
            case dfs.analysis.MultithreadingState.Disabled
                removeSelfFromCache(obj);
            case dfs.analysis.MultithreadingState.NewParent
                reparent(obj);
                data=getDialogData(obj);
            case dfs.analysis.MultithreadingState.RTWData
                data=addMessage(data,'dataflow:MultithreadingAnalysis:Analyze');
            case dfs.analysis.MultithreadingState.ProfiledNoSchedule
                data=addMessage(data,'dataflow:MultithreadingAnalysis:Analyze');
            case dfs.analysis.MultithreadingState.NeedsAutotuning
                data=addMessage(data,'dataflow:MultithreadingAnalysis:Analyze');
            case dfs.analysis.MultithreadingState.SingleThread
                data=getBasicPartitioningDialogData(obj,data);
                data=addTimeStampMessage(data,getString(message('dataflow:MultithreadingAnalysis:UsingSingleThread')));
                data.ShowDiagnosticViewerWarningLink=true;
            case dfs.analysis.MultithreadingState.LatencyMismatch
                data=getBasicPartitioningDialogData(obj,data);
                data.Message=getString(message('dataflow:MultithreadingAnalysis:AnalysisObsolete'));
            case dfs.analysis.MultithreadingState.Partitioned
                data=getPartitioningDialogData(obj,data);
                if data.CurrentLatency<data.SuggestedLatency
                    data.ProgressState.PartitionState=ProgressTrackerEnum.Info;
                end
            case dfs.analysis.MultithreadingState.MinExec
                data=getMinExecDialogData(obj,data);
            case dfs.analysis.MultithreadingState.NoBlocks
                data=getBasicPartitioningDialogData(obj,data);
                data=addTimeStampMessage(data,getString(message('dataflow:MultithreadingAnalysis:NoBlocks')));
            case dfs.analysis.MultithreadingState.ModelSettingsChanged
                data=getBasicPartitioningDialogData(obj,data);
                data.Message=getString(message('dataflow:MultithreadingAnalysis:AnalysisObsolete'));
            otherwise
                assert(false,'Unhandled MultithreadingState');
            end


            if~data.OptimalModelSettings.AllOptimal
                data.Message=[data.Message,newline,newline,getString(message('dataflow:MultithreadingAnalysis:ChangeModelSettings'))];
            end
        end

        function reparent(obj)
            ui=getDataflowUI(obj);
            topHandle=getTopMostDataflowSubsystem(ui,obj.SubsystemHandle);

            cache=dfs.analysis.InstanceCache.getInstance();

            replace(cache,obj.SubsystemHandle,topHandle);

            obj.SubsystemHandle=topHandle;
            setSubsystemHandle(obj.AppHandle,topHandle);

            clearMetaDataCallback(obj);
            createMetaDataCallback(obj);
        end

        function data=getMinExecDialogData(obj,data)
            data=getBasicPartitioningDialogData(obj,data);
            minExecTimeInUs=25;
            if slsvTestingHook('SLMCMinMultithreadExecTime')>0
                minExecTimeInUs=slsvTestingHook('SLMCMinMultithreadExecTime')/1e3;
            end
            data=addTimeStampMessage(data,getString(message('dataflow:MultithreadingAnalysis:NotEnoughWork',round(minExecTimeInUs))));
        end

        function data=getModelSettings(obj,data)
            allOptimal=true;
            model=obj.TopModelHandle;
            for i=1:size(data.OptimalModelSettings.Params,1)
                paramOptimal=strcmpi(get_param(model,data.OptimalModelSettings.Params{i,1}),data.OptimalModelSettings.Params{i,2});
                data.OptimalModelSettings.Params{i,3}=paramOptimal;
                allOptimal=allOptimal&&paramOptimal;
            end
            data.OptimalModelSettings.AllOptimal=allOptimal;
        end

        function data=getBasicPartitioningDialogData(obj,data)
            ui=getDataflowUI(obj);
            assert(~isempty(ui),'No DataflowUI');

            mappingData=getBlkMappingData(ui,obj.SubsystemHandle);
            assert(~isempty(mappingData),'No MappingData');


            if~bitget(mappingData.Attributes,12)
                tallPoleData=mappingData.getCostData.TallPoleData;
                data.TallPoleBlock=tallPoleData.TallPoleBlock;
                data.TallPoleRatio=tallPoleData.TallPoleRatio;
            end

            data.SuggestedLatency=double(mappingData.OptimalLatency);
            data.SuggestedLatencyStr=sprintf('%d',data.SuggestedLatency);



            obj.CachedLatencyValue=double(mappingData.SpecifiedLatency);
            if ui.IsEditPhase||~any(strcmp(get_param(obj.TopModelHandle,'SimulationStatus'),{'stopped','terminating'}))
                obj.CachedLatencyValue=getEvalLatency(ui,obj.SubsystemHandle);
            end
            data.CurrentLatency=obj.CachedLatencyValue;
            data.CurrentLatencyStr=sprintf('%d',data.CurrentLatency);
            numThreads=mappingData.NumberOfThreads;
            if numThreads<1
                numThreads=1;
            end
            data.ThreadsStr=sprintf('%d',numThreads);

            data.ValidData=true;
            data.TimeStamp=mappingData.TimeStamp;



            obj.InfoCache={data.CurrentLatencyStr,data.SuggestedLatencyStr,data.ThreadsStr};
        end

        function data=getPartitioningDialogData(obj,data)


            data=getBasicPartitioningDialogData(obj,data);


            if data.CurrentLatency<data.SuggestedLatency
                data=addTimeStampMessage(data,getString(message('dataflow:MultithreadingAnalysis:AddLatency',data.SuggestedLatencyStr)));
                return;
            end


            if((data.TallPoleRatio>0)&&~isempty(data.TallPoleBlock))

                tallPoleName=data.TallPoleBlock;
                tallPoleName=replace(tallPoleName,[getfullname(obj.SubsystemHandle),'/'],'');
                tallPoleName=replace(tallPoleName,'//','/');
                tallPoleName=regexprep(tallPoleName,'\s',' ');
                tallPoleName=regexprep(tallPoleName,'\s{2,}',' ');

                tallPoleRatioStr=num2str(data.TallPoleRatio,2);
                data=addTimeStampMessage(data,getString(message('dataflow:MultithreadingAnalysis:TallPole',tallPoleName,tallPoleRatioStr)));
                return;
            end



            if~data.OptimalModelSettings.AllOptimal
                data=addTimeStampMessage(data,'');
                return;
            end


            data=addTimeStampMessage(data,getString(message('dataflow:MultithreadingAnalysis:NothingIdentified')));
        end

        function stopTime=evalStopTime(obj)
            stopTimeStr=get_param(obj.TopModelHandle,'StopTime');
            stopTime=-1;
            try
                stopTime=evalin('base',stopTimeStr);
            catch E
                hws=get_param(obj.TopModelHandle,'modelworkspace');
                stopTime=hws.evalin(stopTimeStr);
            end
            if stopTime==-1
                stopTime=1;
            end
        end

    end
end

function data=addMessage(data,messageID)
    data.Message=getString(message(messageID));
end

function data=addTimeStampMessage(data,analysisMessage)
    msgSpacing='';
    if~isempty(analysisMessage)
        msgSpacing=[newline,newline];
    end
    if~isempty(data.TimeStamp)
        data.Message=[getString(message('dataflow:MultithreadingAnalysis:AnalysisComplete')),' ',data.TimeStamp,msgSpacing,analysisMessage];
    else
        data.Message=analysisMessage;
    end
end

function[hTopModel,paths]=getTopModel(hSubsys)









    hParent=get_param(get_param(hSubsys,'parent'),'handle');
    hgcs=get_param(gcs,'handle');
    if hSubsys==hgcs
        activeEditor=SLM3I.SLDomain.getLastActiveEditorFor(hSubsys);
    elseif hParent==hgcs
        activeEditor=SLM3I.SLDomain.getLastActiveEditorFor(hParent);
    else

        hTopModel=get_param(bdroot(hSubsys),'handle');
        return;
    end

    hs=GLUE2.HierarchyService;
    pid=activeEditor.getHierarchyId;
    currentModel=bdroot(hSubsys);
    paths={};


    while~hs.isTopLevel(pid)
        pid=hs.getParent(pid);
        m3Obj=hs.getM3IObject(pid);



        if bdroot(m3Obj.temporaryObject.handle)~=currentModel

            currentModel=bdroot(m3Obj.temporaryObject.handle);

            paths=[{m3Obj.temporaryObject.getFullPathName()},paths];
        end
    end

    m3Obj=hs.getM3IObject(pid);
    hTopModel=m3Obj.temporaryObject.handle;
end



