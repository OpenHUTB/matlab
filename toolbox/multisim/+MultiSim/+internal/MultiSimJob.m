

classdef MultiSimJob<handle
    properties(Dependent)
ModelName
IsRunning
    end

    properties(SetObservable)
        IsDirty(1,1)logical{mustBeNonempty}=false
SimulationManager
    end

    properties
UUID
JobStatusDB
FigureManager




Layout
    end

    properties(Transient=true)
OutputConnection
UIReady
    end

    properties(Access=private,Transient=true)
JobInitialized
StoreData
ParameterNames
Listeners
ModelHandle
    end

    properties(SetAccess=private,GetAccess=public,Transient=true)
requestSimTableDataChannel
receiveSimTableDataChannel
requestSimTableDataChannelSub
SendProgressChannel
SendAlertChannel
SendStoreDataChannel
InitializeSub
ExecutionSub
SDIRunIDs
NotifyAppChannel
Futures
Hyperlink
FetchOutputsFromFuture
FuturesPendingFetch
    end

    properties(Dependent)
NumSims
    end

    methods
        function obj=MultiSimJob(simManager,initializeUIDataFlag)
            obj.JobInitialized=false;
            obj.SimulationManager=simManager;

            if nargin<2
                initializeUIDataFlag=true;
            end

            [~,obj.UUID]=fileparts(tempname);
            obj.JobStatusDB=MultiSim.JobStatusDB(obj,simManager);

            if slfeature('SimulationManagerParameterView')>0
                obj.FigureManager=simmanager.designview.FigureManager(obj);
                addlistener(obj.FigureManager,'IsDirty','PostSet',@obj.handleFigureManagerDirtyFlagChange);
                obj.FigureManager.FigureData=simmanager.designview.internal.FigureData();
            end

            obj.SDIRunIDs=zeros(1,length(simManager.SimulationInputs));

            if initializeUIDataFlag
                obj.initializeUIData();
            end

            obj.setupConnector();
            obj.UIReady=false;
            obj.FetchOutputsFromFuture=false;
            obj.FuturesPendingFetch=false(1,obj.NumSims);

            addlistener(obj.JobStatusDB,'DBChanged',@(~,~)obj.handleJobStatusDBChanged());
            addlistener(obj.JobStatusDB,'SimulationCompleted',...
            @(~,eventData)obj.fetchSimOutput(eventData.Data));
        end

        function set.SimulationManager(obj,simMgr)
            validateattributes(simMgr,{'Simulink.SimulationManager'},{'scalar'});


            if(isempty(obj.SimulationManager)||obj.SimulationManager~=simMgr)
                delete(obj.SimulationManager);
                delete(obj.Listeners);
                obj.SimulationManager=simMgr;
                listeners=[];
                listeners=[listeners,addlistener(simMgr,'JobStarted',@(~,~)obj.handleJobStart())];
                listeners=[listeners,addlistener(simMgr,'SimulationFinished',@obj.handleSimulationFinished)];
                listeners=[listeners,addlistener(simMgr,'AbortSimulations',@obj.handleAbortSimulations)];
                listeners=[listeners,addlistener(simMgr,'SimulationAborted',@obj.handleSimulationAborted)];
                listeners=[listeners,addlistener(simMgr,'ProgressMessageGenerated',@obj.handleProgressMessage)];
                listeners=[listeners,addlistener(simMgr,'JobFinished',@(~,~)obj.handleJobFinished())];
                listeners=[listeners,addlistener(simMgr,'ExecuteReturned',@(~,~)obj.handleExecuteReturned())];
                listeners=[listeners,addlistener(simMgr,'AllSimulationsQueued',...
                @obj.handleAllSimulationsQueued)];
                obj.Listeners=listeners;
            end
        end

        function modelName=get.ModelName(obj)
            modelName=obj.SimulationManager.ModelName;
        end

        function isRunning=get.IsRunning(obj)
            isRunning=obj.JobStatusDB.IsRunning;
        end

        function numSims=get.NumSims(obj)
            numSims=length(obj.SimulationManager.SimulationInputs);
        end

        function out=runSim(obj)


            obj.JobStatusDB.setExecutionStatus(true);








            out=obj.SimulationManager.run();

            if isa(out,'Simulink.SimulationOutput')
                oc=onCleanup(@()obj.JobStatusDB.setExecutionStatus(false));
            else
                obj.Futures=out;
            end
        end

        function saveToFile(obj,fileName)







            try
                simulink.simmanager.FileWriter.checkFileIsWritable(fileName);
            catch ME
                obj.publishAlert(ME.message);
                rethrow(ME);
            end

            serializedJob=MultiSim.internal.getSerializedJob(obj);
            figManager=obj.FigureManager;
            buttonDownFcns(1:numel(figManager.FigureObjects))=struct('FigButtonDownFcn','','AxesButtonDownFcn','');
            for i=1:numel(figManager.FigureObjects)
                figObject=figManager.FigureObjects(i);
                matlabFigure=figObject.MATLABFigure;
                figButtonDown=matlabFigure.ButtonDownFcn;
                axesButtonDown=matlabFigure.CurrentAxes.ButtonDownFcn;
                buttonDownFcns(i).FigButtonDownFcn=figButtonDown;
                buttonDownFcns(i).AxesButtonDownFcn=axesButtonDown;
                matlabFigure.ButtonDownFcn='';
                matlabFigure.CurrentAxes.ButtonDownFcn='';
            end
            oc=onCleanup(@()obj.restoreButtonDownFcns(buttonDownFcns));
            w=simulink.simmanager.FileWriter(serializedJob);
            try
                appName='Simulink_Simulation_Manager';
                fileDescription=message('multisim:FileIO:SimManagerFileDescription').getString();
                w.write(fileName,appName,fileDescription);
            catch ME
                obj.publishAlert(ME.message);
                rethrow(ME);
            end
            obj.IsDirty=false;
        end

        function stop(obj)
            cancel(obj.SimulationManager);
        end

        function delete(obj)
            message.unsubscribe(obj.requestSimTableDataChannelSub);
            message.unsubscribe(obj.InitializeSub);
            message.unsubscribe(obj.ExecutionSub);
            message.unsubscribe(obj.Hyperlink);
            delete(obj.Listeners);

            if obj.IsRunning
                cancel(obj.SimulationManager);
            end
            delete(obj.JobStatusDB);
            delete(obj.FigureManager);
            if ishandle(obj.ModelHandle)
                slInternal('updateSimulationManagerStatusBarLink',obj.ModelHandle,'');
            end
        end
    end

    methods(Access=private)
        function restoreButtonDownFcns(obj,buttonDownFcns)
            figManager=obj.FigureManager;
            for i=1:numel(figManager.FigureObjects)
                figObject=figManager.FigureObjects(i);
                matlabFigure=figObject.MATLABFigure;
                matlabFigure.ButtonDownFcn=buttonDownFcns(i).FigButtonDownFcn;
                matlabFigure.CurrentAxes.ButtonDownFcn=buttonDownFcns(i).AxesButtonDownFcn;
            end
        end

        function handleJobStart(obj)
            obj.Futures=[];
            obj.FetchOutputsFromFuture=false;
            obj.FuturesPendingFetch=false(1,obj.NumSims);
            obj.updateStatusBarForJobStart();
            message.publish(obj.NotifyAppChannel,struct('Event','JobStarted'));
        end

        function handleExecuteReturned(obj)
            obj.updateStatusBarForExecuteReturned();
            message.publish(obj.NotifyAppChannel,struct('Event','ExecuteReturned'));
        end

        function handleJobFinished(obj)
            msg=message('Simulink:MultiSim:ProgressDlgClose');
            outMsg.Identifier=msg.Identifier;
            outMsg.Message=msg.getString();
            message.publish(obj.SendProgressChannel,outMsg);
        end

        function handleJobStatusDBChanged(obj)
            obj.initializeUIData();
            obj.initializeHandler();
        end

        function handleAllSimulationsQueued(obj,~,eventData)
            if~isempty(eventData.Data)
                assert(isa(eventData.Data,'Simulink.Simulation.Future'),...
                'eventData must be a Simulink.Simulation.Future');
                obj.Futures=eventData.Data;
                obj.FetchOutputsFromFuture=true;
            end


            msg=message('Simulink:MultiSim:ProgressDlgClose');
            outMsg.Identifier=msg.Identifier;
            outMsg.Message=msg.getString();
            message.publish(obj.SendProgressChannel,outMsg);
        end

        function handleFigureManagerDirtyFlagChange(obj,~,eventData)
            figManagerIsDirty=eventData.AffectedObject.IsDirty;
            obj.IsDirty=obj.IsDirty||figManagerIsDirty;
        end

        function fetchSimOutput(obj,runId)
            if~isempty(obj.Futures)
                futureState=obj.Futures(runId).State;
                if strcmp(futureState,'unavailable')
                    obj.JobStatusDB.FinalStatusReceived(runId)=false;
                    return;
                end
            end
            obj.SimulationManager.dispatchRunsIfNeeded();
            if obj.FetchOutputsFromFuture||all(obj.FuturesPendingFetch)
                if any(obj.FuturesPendingFetch)

                    fetchOutputs(obj.Futures(obj.FuturesPendingFetch));
                    obj.FuturesPendingFetch=false(1,obj.NumSims);
                end
                fetchOutputs(obj.Futures(runId));
            else
                obj.FuturesPendingFetch(runId)=true;
            end
        end

        function setupConnector(obj)
            channelPrefix=['/MultiSimJob/',obj.UUID];
            connector.ensureServiceOn;

            obj.NotifyAppChannel=[channelPrefix,'/notifyApp'];
            obj.requestSimTableDataChannel=[channelPrefix,'/requestSimTableData'];
            obj.receiveSimTableDataChannel=[channelPrefix,'/receiveSimTableData'];
            obj.SendProgressChannel=[channelPrefix,'/progressDialog'];
            obj.SendAlertChannel=[channelPrefix,'/alertDialog'];
            obj.SendStoreDataChannel=[channelPrefix,'/storeData'];
            fhl=@(x)obj.simTableDataRequestHandler(x);
            obj.requestSimTableDataChannelSub=message.subscribe(obj.requestSimTableDataChannel,fhl);
            initializeChannel=[channelPrefix,'/initialize'];
            obj.InitializeSub=message.subscribe(initializeChannel,@(x)obj.initializeHandler(x));

            executionChannel=[channelPrefix,'/execution'];
            obj.ExecutionSub=message.subscribe(executionChannel,@(x)obj.executionHandler(x));
            hyperlinkChannel=[channelPrefix,'/hyperlink'];
            obj.Hyperlink=message.subscribe(hyperlinkChannel,@(x)obj.hyperlinkHandler(x));
        end

        function initializeUIData(obj)


            params=cell(1,obj.NumSims);
            paramStruct=struct('fullname',{},'type',{},'name',{},'displayname',{});
            for i=1:obj.NumSims
                simInputParams=obj.getSimInputParams(i);
                params{i}=simInputParams;
                if isempty(paramStruct)
                    for j=1:numel(simInputParams)
                        paramStruct(j).fullname=simInputParams(j).fullname;
                        paramStruct(j).type=simInputParams(j).type;
                        paramStruct(j).name=simInputParams(j).name;
                    end
                else
                    existingParamsNames=string({paramStruct.fullname});
                    newParamsNames=string({simInputParams.fullname});
                    [addedParamsNames,newParamsIdx]=setdiff(newParamsNames,existingParamsNames);
                    for j=1:numel(addedParamsNames)
                        addedParam=simInputParams(newParamsIdx(j));
                        paramStruct(end+1)=struct('fullname',addedParam.fullname,...
                        'type',addedParam.type,...
                        'name',addedParam.name,...
                        'displayname',[]);%#ok<AGROW>
                    end
                end
            end






            blockParamCounter=1;
            variableCounter=1;
            fullnameToDisplayNameMap=containers.Map('KeyType','char','ValueType','char');
            dataSourceLabels=struct;
            for i=1:numel(paramStruct)
                paramStruct(i).displayname=paramStruct(i).fullname;
                labelString=paramStruct(i).displayname;
                switch paramStruct(i).type
                case 'Block Parameter'
                    if~isvarname(paramStruct(i).fullname)
                        paramStruct(i).displayname="BlockParam"+num2str(blockParamCounter)+"_"+paramStruct(i).name;
                        blockParamCounter=blockParamCounter+1;
                        splitStrings=strsplit(paramStruct(i).fullname,':');
                        blockPath=splitStrings{1};
                        blockPathSplits=strsplit(blockPath,'/');
                        labelString=paramStruct(i).name+": "+blockPathSplits{end};
                    end

                case 'Variable'
                    if~isvarname(paramStruct(i).fullname)
                        paramStruct(i).displayname="Var"+num2str(variableCounter)+"_"+paramStruct(i).name;
                        variableCounter=variableCounter+1;
                        splitStrings=strsplit(paramStruct(i).fullname,':');
                        varWorkspace=splitStrings{1};
                        labelString=paramStruct(i).name+": "+varWorkspace;
                    end
                end
                assert(isvarname(paramStruct(i).displayname),'MultiSimJob:initializeHandler invalid display name');
                dataSourceLabels.(paramStruct(i).displayname)=labelString;
                fullnameToDisplayNameMap(paramStruct(i).fullname)=paramStruct(i).displayname;
            end

            allParamNames=string({paramStruct.fullname});
            jobStatus=obj.JobStatusDB.Status;
            simMetadata=obj.JobStatusDB.SimMetadata;
            storeData=[];
            for i=obj.NumSims:-1:1
                details=jobStatus(i);
                storeData(i).RunId=i;
                storeData(i).SimElapsedWallTime=details.SimElapsedWallTime;
                storeData(i).SimElapsedWallTimeNumeric=details.SimElapsedWallTimeNumeric;
                storeData(i).StatusString=details.StatusString;
                storeData(i).Status=details.Status;
                storeData(i).Progress=details.Progress;
                storeData(i).Machine=details.Machine;
                storeData(i).SimMetadata=simMetadata(i);

                paramArray=params{i};
                numParams=numel(paramArray);
                for j=1:numParams
                    fullName=paramArray(j).fullname;
                    storeData(i).(fullnameToDisplayNameMap(fullName))=paramArray(j);
                end
                paramDiff=numel(allParamNames)-numParams;
                if paramDiff~=0


                    paramNames=string({paramArray.fullname});
                    [missingParams,paramIdx]=setdiff(allParamNames,paramNames);
                    assert(numel(missingParams)==paramDiff,...
                    'MultiSimJob:initializeHandler parameter mismatch');
                    for j=1:numel(missingParams)
                        paramToAdd=paramStruct(paramIdx(j));
                        newParam=struct('index',numParams+j,...
                        'type',paramToAdd.type,...
                        'name',paramToAdd.name,...
                        'value','-',...
                        'fullname',missingParams{j});
                        storeData(i).(fullnameToDisplayNameMap(missingParams{j}))=newParam;
                    end
                end
            end

            obj.StoreData=storeData;
            obj.ParameterNames={paramStruct.displayname};

            if slfeature('SimulationManagerParameterView')>0&&~isempty(storeData)
                figureData(1:numel(storeData))=struct;
                for i=1:(numel(storeData))
                    for j=1:numel(obj.ParameterNames)
                        figureData(i).(obj.ParameterNames{j})=...
                        storeData(i).(obj.ParameterNames{j}).value;
                    end
                    figureData(i).Status=storeData(i).Status;
                end
                obj.FigureManager.DataSourceLabels=dataSourceLabels;
                obj.FigureManager.FigureData.DataSourceLabels=dataSourceLabels;
                obj.FigureManager.FigureData.setFigureData(figureData);
                if isempty(obj.FigureManager.FigureObjects)
                    obj.FigureManager.createFigure(slsim.design.FigureType.ScatterPlot);
                end
                if obj.JobInitialized
                    obj.FigureManager.resetFigures();
                end
            end
        end

        function updateStatusBarForJobStart(obj)
            load_system(obj.ModelName);
            obj.ModelHandle=get_param(obj.ModelName,'Handle');
            slInternal('updateSimulationManagerStatusBarState',...
            obj.ModelHandle,obj.ModelName,'on');
            slInternal('updateSimulationManagerStatusBarLink',...
            obj.ModelHandle,...
            getString(message('Simulink:MultiSim:ViewDetails')));
        end

        function updateStatusBarForExecuteReturned(obj)
            if~bdIsLoaded(obj.ModelName)
                return;
            end

            if~ishandle(obj.ModelHandle)
                obj.ModelHandle=get_param(obj.ModelName,'Handle');
                slInternal('updateSimulationManagerStatusBarState',...
                obj.ModelHandle,obj.ModelName,'on');
            end




            if~obj.SimulationManager.Options.RunInBackground
                slInternal('updateSimulationManagerStatusBarLink',...
                obj.ModelHandle,getString(message(...
                'Simulink:MultiSim:FinalStatusSummary',obj.NumSims)));
            end
            slInternal('updateSimulationManagerStatusBarState',...
            obj.ModelHandle,obj.ModelName,'off');
        end

        function updateStatusBarForSimulationProgress(obj,msg)
            isValidModelHandle=(~isempty(obj.ModelHandle)&&ishandle(obj.ModelHandle));
            if isValidModelHandle&&~obj.SimulationManager.Options.RunInBackground
                slInternal('updateSimulationManagerStatusBarMessage',...
                obj.ModelHandle,msg);
            end
        end
    end

    methods(Access=public)

        function varargout=initializeHandler(obj,~)




            obj.JobStatusDB.updateHeader();

            if obj.SimulationManager.ForRunAll
                obj.initializeUIData();
            end

            msg.StoreData=obj.StoreData;
            msg.ParameterNames=obj.ParameterNames;
            message.publish(obj.SendStoreDataChannel,msg);

            if slfeature('SimulationManagerParameterView')>0
                obj.OutputConnection=MultiSim.internal.OutputManager(obj.SimulationManager);
                obj.FigureManager.FigureData.connectToJob(obj);
                obj.OutputConnection.update(obj.SimulationManager);
            end



            if nargout==1
                varargout{1}=msg;
            end

            obj.JobInitialized=true;
        end

        function simTableDataRequestHandler(obj,idxRange)
            startIdx=idxRange.startIdx;
            endIdx=idxRange.endIdx;
            numSims=length(obj.SimulationManager.SimulationInputs);
            if(endIdx>numSims)
                endIdx=numSims;
            end

            for i=endIdx:-1:startIdx
                simInp=obj.SimulationManager.SimulationInputs(i);
                simInpData=obj.getSimInputParams(simInp);
                rowData=struct('RunId',i);
                if i==endIdx
                    columnHeaders=struct('RunId','Run ID');
                    for j=1:length(simInpData)
                        colName=['col',num2str(j+1)];
                        columnHeaders.(colName)=simInpData(j).name;
                    end
                end

                for j=1:length(simInpData)
                    colName=['col',num2str(j+1)];
                    rowData.(colName)=simInpData(j).value;
                end
                tableData(i-startIdx+1)=rowData;
            end
            msg.columns=columnHeaders;
            msg.data=tableData;
            msg.startIdx=startIdx;
            msg.endIdx=endIdx;
            msg.numSims=numSims;
            message.publish(obj.receiveSimTableDataChannel,msg);
        end

        function paramArray=getSimInputParams(obj,runId)
            simInp=obj.SimulationManager.SimulationInputs(runId);
            paramArray=MultiSim.internal.getParameterStructArrayFromSimulationInput(simInp);
        end

        function hyperlinkHandler(obj,aCallback)
            try
                aPrunedCallback=urldecode(regexprep(aCallback.command,'^matlab:',''));
                eval(aPrunedCallback);
            catch exp

                obj.publishAlert(exp.message);
            end
        end
        function executionHandler(obj,msg)
            switch msg.command
            case 'start'
                obj.run();

            case{'startSim','UIReady'}
                obj.UIReady=true;

            case 'stop'
                cancel(obj.SimulationManager);

            case 'setup'
                try
                    runId=msg.runId;
                    simIn=obj.SimulationManager.SimulationInputs(runId);
                    simIn.applyToModel('OpenModel','on','EnableConfigSetRefUpdate','on');
                catch ME

                    msg=message('Simulink:MultiSim:ApplyToModelError',...
                    ME.message).getString();
                    obj.publishAlert(msg);
                    throwAsCaller(ME);
                end

            case 'help'
                doc('Simulation Manager');

            case 'view'
                numIds=length(msg.runIds);
                resultsAvailable=ones(1,numIds);
                for i=1:numIds
                    runId=msg.runIds(i);

                    if isempty(fieldnames(obj.SimulationManager.SimulationData{runId}))
                        resultsAvailable(i)=0;
                        continue;
                    end
                    simOut=Simulink.SimulationOutput(obj.SimulationManager.SimulationData{runId},...
                    obj.SimulationManager.SimulationMetadata{runId});
                    sdiRunId=obj.SDIRunIDs(runId);

                    if Simulink.sdi.isValidRunID(sdiRunId)

                        Simulink.sdi.deleteRun(sdiRunId);
                    end
                    name=['Run ',int2str(runId),': ',obj.ModelName];
                    sdiRunId=Simulink.sdi.createRun(name,'vars',simOut);
                    if isempty(sdiRunId)
                        resultsAvailable(i)=0;
                        continue;
                    end
                    obj.SDIRunIDs(runId)=sdiRunId;
                end
                if any(resultsAvailable)
                    if~all(resultsAvailable)
                        indexStr=mat2str(sort(msg.runIds(~resultsAvailable)'));
                        obj.publishAlert(message('Simulink:MultiSim:SDIPartialResults',...
                        indexStr).getString(),'warning');
                    end
                    Simulink.sdi.view;
                else
                    obj.publishAlert(message('Simulink:MultiSim:SDINoResults').getString());
                end

            case 'Debug'
                obj.SimulationManager.connectToSimulation(msg.runId);
            end
        end

        function resetJob(obj)
            delete(obj.JobStatusDB);
            obj.JobStatusDB=MultiSim.JobStatusDB(obj.SimulationManager);
        end

        function handleSimulationFinished(obj,~,eventData)
            runId=eventData.RunId;
            md=obj.SimulationManager.SimulationMetadata{runId};
            obj.JobStatusDB.updateFinalStatus(runId,md);
        end

        function handleAbortSimulations(obj,~,eventData)
            obj.JobStatusDB.handleAbortSimulations(eventData);
        end

        function handleSimulationAborted(obj,~,eventData)
            runIds=eventData.RunIds;
            if isempty(runIds)
                return;
            end
            md=obj.SimulationManager.SimulationMetadata{runIds(1)};
            obj.JobStatusDB.handleSimulationAborted(runIds,md);
        end

        function handleProgressMessage(obj,~,eventData)
            outMsg.Identifier=eventData.Message.Identifier;
            progressMessage=eventData.Message.getString();
            obj.updateStatusBarForSimulationProgress(progressMessage);



            if strcmp(outMsg.Identifier,'Simulink:Commands:MultiSimProgress')||...
                strcmp(outMsg.Identifier,'Simulink:Commands:MultiSimProgressError')
                return;
            end

            outMsg.Message=progressMessage;
            message.publish(obj.SendProgressChannel,outMsg);
        end
    end

    methods(Hidden=true)
        function publishAlert(obj,msgText,msgType)

            if nargin==2
                msgType='error';
            end
            outMsg.type=msgType;
            outMsg.text=msgText;
            message.publish(obj.SendAlertChannel,outMsg);
        end
    end
end

