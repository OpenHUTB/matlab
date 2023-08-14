classdef(Sealed,Hidden=true)slccOOPExternalDebuggerInfo<handle








    properties(Constant=true,GetAccess=private)
        SILDebuggerMap=containers.Map;
        WarnStruct=struct('Interpreter','tex','WindowStyle','modal');
    end

    properties(Access=protected)
        InProcessDebugManager=[];
        modelName;
        RaisedNotificationIDs;
        warnDlgH=-1;
    end

    methods(Access=private)
        function this=slccOOPExternalDebuggerInfo()

        end
    end

    methods(Hidden)

        function createSLCCOOPSILDebugger(this,exePID,breakpoints,srcFiles,modelName,isCpp)
            SLCC.OOP.slccOOPExternalDebuggerInfo.getInstance().closeDebuggerStatusOnModel();
            this.modelName=modelName;
            if this.SILDebuggerMap.isKey(exePID)
                info=this.SILDebuggerMap(exePID);
                debuggerInstance=info{1};
                if~isempty(debuggerInstance)...
                    &&isvalid(debuggerInstance)...
                    &&isa(debuggerInstance,'targetframework.services.appexecution.ApplicationDebugManager')

                    try
                        isRunning=debuggerInstance.IsRunning;
                    catch

                        isRunning=false;
                    end

                    if isRunning

                        msgId='Simulink:CustomCode:ExternalDebuggerAlreadyLaunched';
                        SLCC.OOP.slccOOPExternalDebuggerInfo.getInstance().notifyDebuggerStatusOnModel(msgId);
                        SLCC.OOP.slccOOPExternalDebuggerInfo.getInstance().notifyDebuggerDLLLimitOnModel();
                        return;
                    end
                end
                try
                    delete(debuggerInstance);
                catch

                end
                this.SILDebuggerMap.remove(exePID);
            end

            import targetframework.internal.model.foundation.ServiceMethodRequirement;
            options=targetframework.services.appexecution.ExecutionOptions();
            options.ServiceInterfaceRequirements.setMethodRequirement('open',ServiceMethodRequirement.Optional);
            options.ServiceInterfaceRequirements.setMethodRequirement('close',ServiceMethodRequirement.Optional);
            options.ServiceInterfaceRequirements.setMethodRequirement('loadApplication',ServiceMethodRequirement.Optional);
            options.ServiceInterfaceRequirements.setMethodRequirement('unloadApplication',ServiceMethodRequirement.Optional);
            options.ServiceInterfaceRequirements.setMethodRequirement('stopApplication',ServiceMethodRequirement.Optional);
            options.ServiceInterfaceRequirements.setMethodRequirement('getStandardOutput',ServiceMethodRequirement.Optional);
            options.ServiceInterfaceRequirements.setMethodRequirement('getStandardError',ServiceMethodRequirement.Optional);
            options.ServiceInterfaceRequirements.setMethodRequirement('openFile',ServiceMethodRequirement.Optional);


            if isCpp
                lang=target.internal.Language.Cpp;
            else
                lang=target.internal.Language.C;
            end
            appExecutionService=targetframework.services.appexecution.createHostDebugManager(exePID,breakpoints,options,lang);
            appExecutionService.open();
            appExecutionService.load();
            appExecutionService.attach();
            for idx=1:numel(srcFiles)
                if(exist(srcFiles{idx},'file')==2)
                    appExecutionService.openFile(srcFiles{idx});
                end
            end

            if ismac


                pause(10);
            end

            this.SILDebuggerMap(char(exePID))={appExecutionService,breakpoints};
            if ispc
                msgId='Simulink:CustomCode:ExternalDebuggerLaunchedMSVC';
            else
                msgId='Simulink:CustomCode:ExternalDebuggerLaunchedUnix';
            end
            SLCC.OOP.slccOOPExternalDebuggerInfo.getInstance().notifyDebuggerStatusOnModel(msgId);
            SLCC.OOP.slccOOPExternalDebuggerInfo.getInstance().notifyDebuggerDLLLimitOnModel();
        end

        function[debuggerInstance,breakpoints]=getSLCCOOPSILDebugger(this,exePID)
            if this.SILDebuggerMap.isKey(exePID)
                info=this.SILDebuggerMap(exePID);
                debuggerInstance=info{1};
                breakpoints=info{2};
                if~isvalid(debuggerInstance)
                    debuggerInstance=[];
                    breakpoints=[];
                    this.SILDebuggerMap.remove(exePID);
                end
            else
                debuggerInstance=[];
                breakpoints=[];
            end

        end

        function clearSLCCOOPSILDebugger(this,exePID)
            if this.SILDebuggerMap.isKey(exePID)
                try
                    info=this.SILDebuggerMap(exePID);
                    debuggerInstance=info{1};
                    debuggerInstance.detach();
                catch

                end

                try
                    delete(debuggerInstance);
                catch

                end
                this.SILDebuggerMap.remove(exePID);
            end
        end

        function createInProcessDebugger(this,breakpoints,srcFiles,modelName,isCpp)
            SLCC.OOP.slccOOPExternalDebuggerInfo.getInstance().closeDebuggerStatusOnModel();
            this.modelName=modelName;

            if~isempty(this.InProcessDebugManager)...
                &&isvalid(this.InProcessDebugManager)...
                &&isa(this.InProcessDebugManager,'targetframework.services.appexecution.ApplicationDebugManager')
                try
                    isRunning=this.InProcessDebugManager.IsRunning;
                catch

                    isRunning=false;
                end

                if isRunning

                    msgId='Simulink:CustomCode:ExternalDebuggerAlreadyLaunched';
                    SLCC.OOP.slccOOPExternalDebuggerInfo.getInstance().notifyDebuggerStatusOnModel(msgId);
                    SLCC.OOP.slccOOPExternalDebuggerInfo.getInstance().notifyDebuggerDLLLimitOnModel();
                    return;
                end
            end

            if~isempty(this.InProcessDebugManager)
                try
                    delete(this.InProcessDebugManager);
                catch

                end
                this.InProcessDebugManager=[];
            end


            import targetframework.internal.model.foundation.ServiceMethodRequirement;
            options=targetframework.services.appexecution.ExecutionOptions();
            options.ServiceInterfaceRequirements.setMethodRequirement('open',ServiceMethodRequirement.Optional);
            options.ServiceInterfaceRequirements.setMethodRequirement('close',ServiceMethodRequirement.Optional);
            options.ServiceInterfaceRequirements.setMethodRequirement('loadApplication',ServiceMethodRequirement.Optional);
            options.ServiceInterfaceRequirements.setMethodRequirement('unloadApplication',ServiceMethodRequirement.Optional);
            options.ServiceInterfaceRequirements.setMethodRequirement('stopApplication',ServiceMethodRequirement.Optional);
            options.ServiceInterfaceRequirements.setMethodRequirement('getStandardOutput',ServiceMethodRequirement.Optional);
            options.ServiceInterfaceRequirements.setMethodRequirement('getStandardError',ServiceMethodRequirement.Optional);
            options.ServiceInterfaceRequirements.setMethodRequirement('openFile',ServiceMethodRequirement.Optional);

            if isCpp
                lang=target.internal.Language.Cpp;
            else
                lang=target.internal.Language.C;
            end
            this.InProcessDebugManager=targetframework.services.appexecution.createCurrentProcessDebugManager(breakpoints,options,lang);
            this.InProcessDebugManager.open();
            this.InProcessDebugManager.load();
            this.InProcessDebugManager.attach();
            for idx=1:numel(srcFiles)
                if(exist(srcFiles{idx},'file')==2)
                    this.InProcessDebugManager.openFile(srcFiles{idx});
                end
            end
            if ispc
                msgId='Simulink:CustomCode:ExternalDebuggerLaunchedMSVC';
            else
                msgId='Simulink:CustomCode:ExternalDebuggerLaunchedUnix';
            end
            SLCC.OOP.slccOOPExternalDebuggerInfo.getInstance().notifyDebuggerStatusOnModel(msgId);
            SLCC.OOP.slccOOPExternalDebuggerInfo.getInstance().notifyDebuggerDLLLimitOnModel();
            SLCC.OOP.slccOOPExternalDebuggerInfo.getInstance().showWarnDlg();
        end

        function clearSLCCInProcessDebugger(this)
            if~isempty(this.InProcessDebugManager)
                try
                    this.InProcessDebugManager.detach();
                    compArch=computer('arch');
                    if strcmp(compArch,'glnxa64')

                        pause(60);
                    end
                catch

                end
                try
                    delete(this.InProcessDebugManager);
                catch

                end
                this.InProcessDebugManager=[];
                SLCC.OOP.slccOOPExternalDebuggerInfo.getInstance().closeWarnDlg();
            end
        end

        function reattachProcessToDebugger(this,exePID,isOOP)
            debuggerInstance=[];
            if isOOP
                if this.SILDebuggerMap.isKey(exePID)
                    info=this.SILDebuggerMap(exePID);
                    debuggerInstance=info{1};
                else
                    return;
                end
            else
                debuggerInstance=this.InProcessDebugManager;
            end

            if~isempty(debuggerInstance)&&isa(debuggerInstance,'targetframework.services.appexecution.ApplicationDebugManager')
                try
                    if debuggerInstance.IsRunning

                        return;
                    else
                        debuggerInstance.attach();
                    end
                catch

                    debuggerInstance.release();
                    if isOOP
                        if this.SILDebuggerMap.isKey(exePID)
                            SLCC.OOP.slccOOPExternalDebuggerInfo.getInstance().clearSLCCOOPSILDebugger(exePID);
                        end
                    else
                        SLCC.OOP.slccOOPExternalDebuggerInfo.getInstance().clearSLCCInProcessDebugger();
                    end
                    SLCC.OOP.slccOOPExternalDebuggerInfo.getInstance().closeDebuggerStatusOnModel();
                    msgId='Simulink:CustomCode:ExternalDebuggerSessionEnd';
                    SLCC.OOP.slccOOPExternalDebuggerInfo.getInstance().notifyDebuggerStatusOnModel(msgId);
                end
            end
        end

        function notifyDebuggerStatusOnModel(this,notificationID,varargin)
            editor=GLUE2.Util.findAllEditors(this.modelName);
            if~isempty(editor)
                notificationMsg=DAStudio.message(notificationID,varargin{:});
                editor.deliverInfoNotification(notificationID,notificationMsg);
                this.RaisedNotificationIDs{end+1}=notificationID;
            end
        end

        function closeDebuggerStatusOnModel(this)
            if isempty(this.RaisedNotificationIDs)
                return;
            end
            editor=GLUE2.Util.findAllEditors(this.modelName);
            if~isempty(editor)
                for idx=1:numel(this.RaisedNotificationIDs)
                    editor.closeNotificationByMsgID(char(this.RaisedNotificationIDs(idx)));
                end
            end
        end

        function notifyDebuggerDLLLimitOnModel(this)
            if~ispc
                return
            end

            customCodeSettings=CGXE.CustomCode.CustomCodeSettings.createFromModel(this.modelName);

            compilerInfo=cgxeprivate('compilerman','get_compiler_info',customCodeSettings.isCpp);
            compiler=compilerInfo.compilerName;
            if ismember(compiler,cgxeprivate('supportedPCCompilers','microsoft'))
                debuggerMaxModule=500;
                try
                    debuggerMaxModule=winqueryreg('HKEY_LOCAL_MACHINE','SYSTEM\CurrentControlSet\Control\Session Manager','DebuggerMaxModuleMsgs');
                catch

                end
                if debuggerMaxModule<4096
                    msgId='Simulink:CustomCode:ExternalDebuggerMSVCDLLLimit';
                    SLCC.OOP.slccOOPExternalDebuggerInfo.getInstance().notifyDebuggerStatusOnModel(msgId,debuggerMaxModule);
                end
            end
        end

        function showWarnDlg(this)
            if isunix
                SLCC.OOP.slccOOPExternalDebuggerInfo.getInstance().closeWarnDlg();
                this.warnDlgH=warndlg(getString(message('Simulink:CustomCode:ExternalDebuggerLaunchingWarnDlgMsgUnix')),'Warning',this.WarnStruct);
            end
        end

        function closeWarnDlg(this)
            if isunix&&ishandle(this.warnDlgH)
                close(this.warnDlgH);
            end
        end

    end

    methods(Static)
        function SLCCOOPExternalDebuggerInfoObj=getInstance()
            persistent localObj

            if isempty(localObj)||~isvalid(localObj)
                localObj=SLCC.OOP.slccOOPExternalDebuggerInfo();
            end

            SLCCOOPExternalDebuggerInfoObj=localObj;
        end
    end

end

