function ToolStrip(fncname,cbinfo,varargin)



    fcn=str2func(fncname);
    fcn(cbinfo,varargin{:});
end

function TargetSelectionRF(cbinfo,varargin)
    if ismac
        return;
    end

    action=varargin{1};

    appContext=slrealtime.internal.ToolStripContextMgr.getContext(cbinfo.model.Name);
    if isempty(appContext)
        return;
    end
    c=onCleanup(@()appContext.synchToolStripWithSelectedTarget());

    if appContext.doNotInitializeTargets
        return;
    end

    action.enabled=appContext.targetSelectEnabled;

    availTargets=slrealtime.internal.ToolStripContextMgr.getAvailableTargets();

    action.validateAndSetEntries(availTargets);
    appContext.targetEntries=availTargets;
    if~isempty(appContext.selectedTarget)&&...
        ~any(cellfun(@(x)strcmp(x,appContext.selectedTarget),appContext.targetEntries,'UniformOutput',true))
        action.selectedItem=slrealtime.internal.ToolStripContextMgr.getDefaultTarget();
    else
        action.selectedItem=appContext.selectedTarget;
    end
    appContext.selectedTarget=action.selectedItem;
end

function TargetSelectionOpenCB(cbinfo)
    appContext=slrealtime.internal.ToolStripContextMgr.getContext(cbinfo.model.Name);
    appContext.doNotInitializeTargets=false;
end

function SelectedTargetChangedCB(cbinfo,varargin)
    selectedItem=cbinfo.EventData;
    appContext=slrealtime.internal.ToolStripContextMgr.getContext(cbinfo.model.Name);
    appContext.selectedTarget=selectedItem;
end

function TargetConnectDisconnectCB(cbinfo,varargin)
    appContext=slrealtime.internal.ToolStripContextMgr.getContext(cbinfo.model.Name);
    isConnecting=strcmp(appContext.connectionStatusText,'slrealtime:toolstrip:RealTimeTargetConnectionStatusLabelActionDisconnectedText');





    if isConnecting
        appContext.blockToolStrip(getString(message('slrealtime:toolstrip:ConnectingToTargetComputer')));
    else
        appContext.blockToolStrip(getString(message('slrealtime:toolstrip:DisconnectingFromTargetComputer')));
    end

    w=warning('off','backtrace');
    c=onCleanup(@()warning(w));

    try
        if isConnecting
            appContext.connectionStatusText='slrealtime:toolstrip:ConnectingToTarget';
            tg=slrealtime(appContext.selectedTarget);
            tg.connect();
        else
            appContext.connectionStatusText='slrealtime:toolstrip:DisconnectingFromTarget';
            tg=slrealtime(appContext.selectedTarget);
            tg.disconnect();
        end
    catch ME
        appContext.synchToolStripWithSelectedTarget();
        rethrow(ME);
    end
end

function ConfigureRealTimeCB(cbinfo,varargin)
    modelName=cbinfo.model.Name;
    configset.showParameterGroup(modelName,{'Code Generation','Simulink Real-Time Options'});
end

function RealTimeExplorerCB(cbinfo,varargin)%#ok
    slrtExplorer;
end

function RunOnTargetCB(cbinfo,varargin)
    appContext=slrealtime.internal.ToolStripContextMgr.getContext(cbinfo.model.Name);
    switch appContext.runOnTargetRealTimeAction
    case 'oneClickRealTimeAction'
        OneClickCB(cbinfo,{});
    case 'stopRealTimeApplicationAction'
        StopCB(cbinfo,{});
    case 'runRealTimeApplicationAction'
        StartCB(cbinfo,{});
    otherwise
        assert(false);
    end
end

function OneClickRF(cbinfo,varargin)
    action=varargin{1};
    appContext=slrealtime.internal.ToolStripContextMgr.getContext(cbinfo.model.Name);
    if isempty(appContext)
        return;
    end

    action.enabled=appContext.oneClickRealTimeEnabled;
end

function OneClickCB(cbinfo,varargin)
    modelName=cbinfo.model.Name;
    appContext=slrealtime.internal.ToolStripContextMgr.getContext(modelName);





    w=warning('off','Simulink:utility:ScopedStudioBlockerWarning');
    c=onCleanup(@()warning(w));
    appContext.blockToolStrip('');

    try
        disconnected=strcmp(appContext.connectionStatusText,'slrealtime:toolstrip:RealTimeTargetConnectionStatusLabelActionDisconnectedText');
        if disconnected
            TargetConnectDisconnectCB(cbinfo,{});
        end

        try

            StopCB(cbinfo,{});
        catch
        end


        tg=slrealtime(appContext.selectedTarget);
        [isRunning,runningApp]=tg.isRunning();
        if isRunning
            DAStudio.error('slrealtime:toolstrip:TargetRunning',appContext.selectedTarget,modelName,runningApp);
        end


        if strcmp(get_param(modelName,'ExtMode'),'off')
            DAStudio.error('slrealtime:toolstrip:ExtModeDisabled',modelName);
        end

        codeGenFolder=Simulink.fileGenControl('get','CodeGenFolder');
        if isempty(codeGenFolder)
            codeGenFolder=pwd;
        end
        file=fullfile(codeGenFolder,modelName);

        skipBuild=false;
        canceled=false;
        try
            if strcmp(get_param(modelName,'dirty'),'off')
                if exist(strcat(file,'.mldatx'),'file')

                    skipBuild=true;
                    DeployCB(cbinfo,{});
                    ConnectModelCB(cbinfo,{});
                    [canceled,failed]=ConnectModelWaitToFinish(modelName,appContext);
                    if failed
                        skipBuild=false;
                    end
                end
            end
        catch
            skipBuild=false;
        end

        if canceled
            return;
        end

        if~skipBuild

            mldatxName=strcat(file,'.mldatx');
            origDateStr=[];
            if exist(mldatxName,'file')
                f=dir(mldatxName);
                origDateStr=f.date;
            end

            BuildCB(cbinfo,{});


            if~exist(strcat(file,'.mldatx'),'file')

                return;
            else
                f=dir(mldatxName);
                newDateStr=f.date;
                if strcmp(origDateStr,newDateStr)

                    return;
                end
            end

            DeployCB(cbinfo,{});
            ConnectModelCB(cbinfo,{});
            [canceled,failed]=ConnectModelWaitToFinish(modelName,appContext);
            if failed
                DAStudio.error('slrealtime:toolstrip:TimedOutWaitingForExtModeConnect');
            end
        end

        if canceled
            return;
        end

        StartCB(cbinfo,{});

    catch ME
        appContext.synchToolStripWithSelectedTarget();
        DAStudio.error('slrealtime:toolstrip:OneClickError',modelName,ME.message);
    end
end

function BuildCB(cbinfo,varargin)
    cbinfo.domain.buildModel(cbinfo.model.handle);
end

function DeployCB(cbinfo,varargin)
    modelName=cbinfo.model.Name;
    appContext=slrealtime.internal.ToolStripContextMgr.getContext(modelName);




    appContext.blockToolStrip(getString(message('slrealtime:toolstrip:DeployingToTargetComputer')));

    codeGenFolder=Simulink.fileGenControl('get','CodeGenFolder');
    if isempty(codeGenFolder)
        codeGenFolder=pwd;
    end
    file=fullfile(codeGenFolder,modelName);
    if~exist(strcat(file,'.mldatx'),'file')
        MLDATXFilter=getString(message('slrealtime:toolstrip:MLDATXFilter'));
        MLDATXDesc=getString(message('slrealtime:toolstrip:MLDATXDesc'));
        MLDATXLoadTitle=getString(message('slrealtime:toolstrip:MLDATXLoadTitle'));

        [filename,pathname]=...
        uigetfile({MLDATXFilter,MLDATXDesc},MLDATXLoadTitle);
        if isequal(filename,0)||isequal(pathname,0)
            appContext.synchToolStripWithSelectedTarget();
            return;
        end
        if~isequal(matlabshared.mldatx.internal.getApplication(fullfile(pathname,filename)),'slrealtime_Application')
            DAStudio.error('slrealtime:toolstrip:InvalidApp',filename);
        end
        [~,name,~]=fileparts(filename);
        file=fullfile(pathname,name);
    end

    tg=slrealtime(appContext.selectedTarget);
    tg.connect();
    if tg.isConnected()
        tg.load(file);
    end
end

function ConnectModelCB(cbinfo,varargin)
    modelName=cbinfo.model.Name;
    appContext=slrealtime.internal.ToolStripContextMgr.getContext(modelName);





    appContext.blockToolStrip('');








    dirty=get_param(modelName,'dirty');




    extmodeParams={...
    {'ExtModeOpenProtocolUploadingEqualLengthVectors','on'};...
    {'ExtModeAutoUpdateStatusClock','on'};...
    {'ExtModeEnableFloating','off'};...
    {'ExtModeLogAll','on'};...
    {'ExtModeTrigType','manual'};...
    {'ExtModeTrigMode','normal'};...
    {'ExtModeTrigDuration',1000};...
    {'ExtModeTrigDelay',0};...
    {'ExtModeArmWhenConnect','on'};...
    {'ExtModeArchiveMode','off'};
    };



    for nParam=1:length(extmodeParams)
        extmodeParams{nParam}{3}=get_param(modelName,extmodeParams{nParam}{1});
    end



    for nParam=1:length(extmodeParams)
        set_param(modelName,extmodeParams{nParam}{1},extmodeParams{nParam}{2});
    end




    if strcmp(dirty,'off')
        set_param(modelName,'dirty','off');
    end

    appContext.extmodeParams=extmodeParams;

    if~strcmp('external',get_param(modelName,'SimulationMode'))&&...
        strcmp('off',get_param(modelName,'UseTemporaryMenuSimulationMode'))
        set_param(modelName,'UseTemporaryMenuSimulationMode','on');
        set_param(modelName,'TemporaryMenuSimulationMode','external');
    end

    set_param(modelName,'SimulationCommand','connect');
end

function[canceled,failed]=ConnectModelWaitToFinish(modelName,appContext)
    canceled=false;
    failed=false;




    if strcmp(get_param(modelName,'ExtModeConnected'),'off')
        failed=true;
        figs=allchild(0);
        if~isempty(figs)
            idxs=strcmp({figs.Tag},'Targets_External_mode_Error');
            if~isempty(idxs)
                close(figs(idxs));
            end
        end
        return;
    end












    appContext.blockToolStrip(getString(message('slrealtime:toolstrip:WaitingToConnect')));
    c1=onCleanup(@()appContext.unblockToolStrip());
    timedout=true;

    while 1
        if strcmp(get_param(modelName,'ExtModeStartButtonEnabled'),'on')
            timedout=false;
            break;
        end

        figs=allchild(0);
        if~isempty(figs)
            idxs=strcmp({figs.Tag},'Targets_External_mode_Error');
            if~isempty(idxs)
                failed=true;
                close(figs(idxs));
                break;
            end
        end
    end
    if timedout
        failed=true;
    end












































end

function StartRF(cbinfo,varargin)
    action=varargin{1};
    appContext=slrealtime.internal.ToolStripContextMgr.getContext(cbinfo.model.Name);
    if isempty(appContext)
        return;
    end

    action.enabled=appContext.startRealTimeEnabled;
end

function StartCB(cbinfo,varargin)
    modelName=cbinfo.model.Name;
    appContext=slrealtime.internal.ToolStripContextMgr.getContext(modelName);





    appContext.blockToolStrip('');

    set_param(cbinfo.model.Name,'SimulationCommand','start');
end

function RestartCB(cbinfo,varargin)
    set_param(cbinfo.model.Name,'ExtModeOpenProtocolRestart',0);
end

function StopRF(cbinfo,varargin)
    action=varargin{1};
    appContext=slrealtime.internal.ToolStripContextMgr.getContext(cbinfo.model.Name);
    if isempty(appContext)
        return;
    end

    action.enabled=appContext.stopRealTimeEnabled;
end

function StopCB(cbinfo,varargin)
    modelName=cbinfo.model.Name;
    appContext=slrealtime.internal.ToolStripContextMgr.getContext(modelName);





    appContext.blockToolStrip('');

    set_param(cbinfo.model.Name,'SimulationCommand','stop');
end

function ModelDisconnectCB(cbinfo,varargin)
    modelName=cbinfo.model.Name;
    appContext=slrealtime.internal.ToolStripContextMgr.getContext(modelName);





    appContext.blockToolStrip('');

    set_param(cbinfo.model.Name,'SimulationCommand','disconnect');
end

function TETMonitorCB(cbinfo,varargin)%#ok
    slrtTETMonitor;
end

function recordingControlCB(cbinfo,varargin)
    modelName=cbinfo.model.Name;
    appContext=slrealtime.internal.ToolStripContextMgr.getContext(modelName);
    tg=slrealtime(appContext.selectedTarget);

    appContext.blockToolStrip('');
    c=onCleanup(@()appContext.unblockToolStrip());
    if strcmp(appContext.recordingControlIcon,'stopRecording')
        tg.stopRecording();
    else
        tg.startRecording();
    end
end

function configureInstrumentCB(cbinfo,varargin)
    modelName=cbinfo.model.Name;
    appContext=slrealtime.internal.ToolStripContextMgr.getContext(modelName);
    tg=slrealtime(appContext.selectedTarget);
    tg.configureStreaming(modelName);
end

function removeInstrumentCB(cbinfo,varargin)
    modelName=cbinfo.model.Name;
    appContext=slrealtime.internal.ToolStripContextMgr.getContext(modelName);
    tg=slrealtime(appContext.selectedTarget);
    tg.stopStreaming();
end

function highlightInstrumentCB(cbinfo,varargin)
    modelName=cbinfo.model.Name;
    appContext=slrealtime.internal.ToolStripContextMgr.getContext(modelName);
    tg=slrealtime(appContext.selectedTarget);
    tg.highlightStreaming();
end

function importInstrumentCB(cbinfo,varargin)
    modelName=cbinfo.model.Name;
    appContext=slrealtime.internal.ToolStripContextMgr.getContext(modelName);
    tg=slrealtime(appContext.selectedTarget);
    tg.importStreaming();
end

function exportInstrumentCB(cbinfo,varargin)
    modelName=cbinfo.model.Name;
    appContext=slrealtime.internal.ToolStripContextMgr.getContext(modelName);
    tg=slrealtime(appContext.selectedTarget);
    tg.exportStreaming();
end

function createInstrumentPanelCB(cbinfo,varargin)
    slrtAppGenerator(cbinfo.model.Name);
end

function CANExplorerCB(cbinfo,varargin)%#ok
    canExplorer;
end

function CANFDExplorerCB(cbinfo,varargin)%#ok
    canFDExplorer;
end
