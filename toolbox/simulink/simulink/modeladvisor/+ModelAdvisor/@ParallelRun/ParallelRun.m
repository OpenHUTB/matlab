classdef ParallelRun<handle
    properties(Access=private)
        parallelinfoFile;
        timerForMAParallelRun;
        parallelJob;
        snapShot=[];
        mdladvObj;
    end

    properties(Access=public)
        pwd;
    end

    methods(Access=private)

        function obj=ParallelRun()
        end
    end


    methods(Access=public)

        function startRun(obj,mdladvObj,taskID)
            obj.mdladvObj=mdladvObj;
            obj.takeSnapshot(mdladvObj,taskID);
            obj.freezeMA();
            obj.startParallelRun();
            obj.initiateTimer();
        end

        function out=getparallelinfoFile(obj)
            out=obj.parallelinfoFile;
        end

        function takeSnapshot(obj,mdladvObj,ID)
            obj.snapShot=ModelAdvisor.Snapshot(mdladvObj,ID);
        end

        function out=getSnapshot(obj)
            out=obj.snapShot;
        end

        function startParallelRun(obj)
            try
                debug=false;
                if~debug

                    parallelPool=gcp('nocreate');
                    if isempty(parallelPool)
                        obj.mdladvObj.setStatus(DAStudio.message('ModelAdvisor:engine:BackgroundRunParallelLaunch'));
                        evalc('parallelPool=parpool(1);');
                    end
                    obj.mdladvObj.setStatus(DAStudio.message('ModelAdvisor:engine:BackgroundRunInitializing'));
                    obj.parallelJob=parfeval(parallelPool,@ModelAdvisor.ParallelRun.initiateRun,0,obj.mdladvObj.Database.FileLocation);
                end
            catch E
                if~isempty(E.cause)&&iscell(E.cause)&&isa(E.cause{1},'ParallelException')
                    return;
                end
            end
        end

        function serialize(obj)
            obj.snapShot.serialize();
        end

        function freezeMA(obj)
            dashboard=ModelAdvisorLite.GUIModelAdvisorLite.findMALiteDialog(gcs);
            if~isempty(dashboard)
                dashboard.getSource.eventBroadcast('MESleep');
            end
            obj.mdladvObj.isSleeping=true;
            obj.switchMenus('off');
        end

        function switchMenus(obj,value)
            if~isempty(obj.mdladvObj.meMenus)
                fields=fieldnames(obj.mdladvObj.meMenus);
                for i=1:length(fields)
                    obj.mdladvObj.meMenus.(fields{i}).enabled=value;
                end
                obj.mdladvObj.meMenus.ShowInformerGUI.enabled='on';
            end
            if~isempty(obj.mdladvObj.Toolbar)
                fields=fieldnames(obj.mdladvObj.Toolbar);
                for i=1:length(fields)
                    if isa(obj.mdladvObj.Toolbar.(fields{i}),'DAStudio.Action')
                        obj.mdladvObj.Toolbar.(fields{i}).enabled=value;
                    end
                end
                if isfield(obj.mdladvObj.Toolbar,'runCheck')&&...
                    ~isa(obj.mdladvObj.Toolbar.runCheck,'DAStudio.Action')
                    return;
                end
                obj.mdladvObj.Toolbar.launchLiteUI.enabled='on';
                obj.mdladvObj.Toolbar.runCheck.enabled='on';
                if strcmp(value,'off')
                    obj.mdladvObj.Toolbar.runCheck.icon=fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','resources','stop.png');
                    obj.mdladvObj.Toolbar.runCheck.Text=DAStudio.message('ModelAdvisor:engine:BackgroundRunCancelTooltip');
                else
                    obj.mdladvObj.Toolbar.runCheck.icon=fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','resources','run_small.png');
                    obj.mdladvObj.Toolbar.runCheck.Text=DAStudio.message('ModelAdvisor:engine:ToolbarRunChecks');
                end
            end
        end

        function restoreModelAdvisor(obj)
            obj.switchMenus('on');
            obj.mdladvObj.isSleeping=false;
            ed=DAStudio.EventDispatcher;
            ed.broadcastEvent('HierarchyChangedEvent',obj.mdladvObj.taskAdvisorRoot);
            obj.mdladvObj.setStatus('');
            dashboard=ModelAdvisorLite.GUIModelAdvisorLite.findMALiteDialog(obj.mdladvObj.systemName);
            if~isempty(dashboard)
                dashboard.getSource.eventBroadcast('MEWake');
            end
            editor=GLUE2.Util.findAllEditors(obj.mdladvObj.systemName);
            messageStart=['<a href="matlab:modeladvisor(bdroot)">',DAStudio.message('ModelAdvisor:engine:BackgroundRunResults'),'</a>'];
            fullMessage=DAStudio.message('ModelAdvisor:engine:BackgroundRunResultsAvailable',messageStart);

            if~isempty(editor)
                editor.deliverInfoNotification('modeladvisor.parallel.resultsAvailable',fullMessage);
            end

            ModelAdvisor.Node.toggleCheckResultOverlay('GUI');

            taskObj=obj.mdladvObj.getTaskObj(obj.snapShot.TaskID);
            if(isa(taskObj,'ModelAdvisor.Group')&&taskObj.LaunchReport)||(isjava(obj.mdladvObj.BrowserWindow)&&obj.mdladvObj.BrowserWindow.isShowing)
                taskObj.viewReport('');
            end


            Advisor.Utils.refreshCurrentMATreeNodeDialog(obj.mdladvObj);
        end

        function initiateTimer(obj)
            if~isempty(obj.timerForMAParallelRun)
                delete(obj.timerForMAParallelRun);
            end
            obj.timerForMAParallelRun=timer('ExecutionMode','fixedRate','BusyMode','drop','Period',5,'TimerFcn',@(x,y)ModelAdvisor.ParallelRun.getInstance.timerForParallelMode);
            start(obj.timerForMAParallelRun);
        end

        function stopTimer(obj)
            obj.cleanup();
        end

        function status=getJobStatus(obj)
            status='';
            if~isempty(obj.parallelJob)

                status=obj.parallelJob.State;
            end
        end

        function cancelRun(obj)
            try
                obj.mdladvObj.Database.overwriteLatestData('ParallelInfo','cancel',int32(1));
            catch E %#ok<NASGU>
                parallelRun=ModelAdvisor.ParallelRun.getInstance();
                parallelRun.cancelRun();
            end
        end

        function cleanup(obj)
            obj.stop();
            obj.restoreModelAdvisor();
        end

        function stop(obj)
            if~isempty(obj.timerForMAParallelRun)
                stop(obj.timerForMAParallelRun);
                delete(obj.timerForMAParallelRun);
                obj.timerForMAParallelRun=[];
            end
            if~isempty(obj.parallelJob)
                if~strcmp(obj.parallelJob.State,'finished')
                    obj.parallelJob.cancel;
                end
                e=obj.parallelJob.Error;
                if~isempty(e)
                    if~strcmp(e.identifier,'parallel:fevalqueue:ExecutionCancelled')
                        disp(e.message);
                    end
                end
                obj.parallelJob.delete;
                obj.parallelJob=[];
                obj.importParallelRunResults();
            end
        end
    end

    methods(Static=true)
        function singleObj=getInstance()
            persistent localStaticObj;
            if isempty(localStaticObj)||~isvalid(localStaticObj)&&~localStaticObj.getCleared
                localStaticObj=ModelAdvisor.ParallelRun();
            end
            singleObj=localStaticObj;
        end

        function status=getStatus()
            instance=ModelAdvisor.ParallelRun.getInstance();
            status=instance.getJobStatus();
        end

        function initiateRun(dataRespositoryFilePath)

            try
                modelAdvisorTempDir=tempname;
                rds=exist(modelAdvisorTempDir,'dir');
                if rds==0
                    mkdir(modelAdvisorTempDir);
                else
                    DAStudio.error('MATLAB:depfun:req:InternalCreateRulesDirFail',...
                    modelAdvisorTempDir)
                end

                oldInformerPref=getpref('modeladvisor','ShowInformer');
                setpref('modeladvisor','ShowInformer',0);
                dataRepository=ModelAdvisor.Repository(dataRespositoryFilePath);
                dataRepository.overwriteLatestData('ParallelInfo','status',{DAStudio.message('ModelAdvisor:engine:BackgroundRunSetup')});
                mdladvInfo=dataRepository.loadData('MdladvInfo');
                isConfig=false;
                configName='';
                if~isempty(mdladvInfo.ConfigFilePathInfo)&&...
                    isfield(mdladvInfo.ConfigFilePathInfo,'name')&&...
                    ~isempty(mdladvInfo.ConfigFilePathInfo.name)
                    isConfig=true;
                    configName=mdladvInfo.ConfigFilePathInfo.name;
                end

                parallelRunInformation=dataRepository.loadData('ParallelInfo');
                addpath(parallelRunInformation.pwd);
                dataRepository.overwriteLatestData('ParallelInfo','status',{DAStudio.message('ModelAdvisor:engine:BackgroundRunLoading')});
                if~isempty(parallelRunInformation)&&...
                    isfield(parallelRunInformation,'cancel')&&...
                    ~isempty(parallelRunInformation.cancel)&&(parallelRunInformation.cancel==1)
                    setpref('modeladvisor','ShowInformer',oldInformerPref);
                    cd(parallelRunInformation.pwd);
                    [success,messagestr,messageid]=rmdir(modelAdvisorTempDir,'s');%#ok<ASGLU>
                    rmpath(parallelRunInformation.pwd);
                    delete(dataRepository);
                    return;
                end
                modelName=fullfile(parallelRunInformation.snapshotPath,parallelRunInformation.system);


                close_system(modelName,0);
                close_system(parallelRunInformation.system);
                load_system(modelName);
                cd(modelAdvisorTempDir);

                evalin('base','clear');
                evalin('base',['load(''',parallelRunInformation.workspaceMat,''')']);
                am=Advisor.Manager.getInstance;
                am.ApplicationObjMap.remove(am.ApplicationObjMap.keys);
                am.setParallelDatabase(dataRespositoryFilePath);
                dataRepository.overwriteLatestData('ParallelInfo','status',{DAStudio.message('ModelAdvisor:engine:BackgroundRunInitializing')});
                parallelRunInformation=dataRepository.loadData('ParallelInfo');

                if~isempty(parallelRunInformation)&&...
                    isfield(parallelRunInformation,'cancel')&&...
                    ~isempty(parallelRunInformation.cancel)&&(parallelRunInformation.cancel==1)
                    setpref('modeladvisor','ShowInformer',oldInformerPref);
                    cd(parallelRunInformation.pwd);
                    [success,messagestr,messageid]=rmdir(modelAdvisorTempDir,'s');%#ok<ASGLU>
                    rmpath(parallelRunInformation.pwd);
                    delete(dataRepository);
                    return;
                end
                if~isConfig
                    modeladvisor(parallelRunInformation.sysPath);
                else
                    modeladvisor(parallelRunInformation.sysPath,'configuration',configName);
                end
                mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;%#ok<*PROP>
                if strcmp(parallelRunInformation.TaskID,'SysRoot')
                    node=mdladvObj.TaskAdvisorRoot;
                else
                    node=mdladvObj.getTaskObj(parallelRunInformation.TaskID);
                end
                parallelRunInformation=dataRepository.loadData('ParallelInfo');
                if~isempty(parallelRunInformation)&&...
                    isfield(parallelRunInformation,'cancel')&&...
                    ~isempty(parallelRunInformation.cancel)&&(parallelRunInformation.cancel==1)
                    setpref('modeladvisor','ShowInformer',oldInformerPref);
                    cd(parallelRunInformation.pwd);
                    [success,messagestr,messageid]=rmdir(modelAdvisorTempDir,'s');%#ok<ASGLU>
                    rmpath(parallelRunInformation.pwd);
                    delete(dataRepository);
                    return;
                end
                if~isempty(node)
                    node.runTaskAdvisor;
                end
                mdladvObj.Database.overwriteLatestData('ParallelInfo','status',{DAStudio.message('ModelAdvisor:engine:BackgroundRunCompleted')});
                close_system(modelName,0);
                setpref('modeladvisor','ShowInformer',oldInformerPref);
                cd(parallelRunInformation.pwd);
                [success,messagestr,messageid]=rmdir(modelAdvisorTempDir,'s');%#ok<ASGLU>
                rmpath(parallelRunInformation.pwd);
                delete(dataRepository);
            catch E
                close_system(modelName,0);
                rethrow(E);
            end
        end
    end
end
