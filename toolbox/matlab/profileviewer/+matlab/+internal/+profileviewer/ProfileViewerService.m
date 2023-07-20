classdef ProfileViewerService<matlab.internal.profileviewer.ImplManagerClient



    properties(Access=private)
ProfilerState
DataModel
MessageService
BrowserService
ProfileInterface
UINotificationPolicy
    end

    properties(SetAccess=private,Hidden)
        IsUIInitialized=false;
        ClientId;
    end

    properties(Dependent,Hidden)
LastProfilerAction
    end

    methods(Static)
        function obj=getInstance(profilerType)

            mlock;
            persistent instance
            if isempty(instance)||~isvalid(instance)
                implManager=matlab.internal.profileviewer.ImplManager;
                implManager.setCurrentImpl(profilerType);
                instance=matlab.internal.profileviewer.ProfileViewerService(implManager);
            end


            instance.swapProfilerImplsIfChanged(profilerType);
            obj=instance;
        end
    end

    methods
        function lastAction=get.LastProfilerAction(obj)

            lastAction=obj.ImplManagerInstance.getProfilerState().getLastAction();
        end
    end

    methods(Hidden)

        function swapProfilerImplsIfChanged(obj,profilerType)
            if obj.ImplManagerInstance.CurrentProfilerType~=profilerType
                obj.ImplManagerInstance.setCurrentImpl(profilerType)
            end
        end

        function initializeUI(obj)
            if~obj.IsUIInitialized

                connector.ensureServiceOn;


                obj.BrowserService=matlab.internal.profileviewer.BrowserService(obj.ClientId,obj.ImplManagerInstance);


                obj.MessageService=matlab.internal.profileviewer.MessageService(obj.ClientId,obj.ImplManagerInstance);
                obj.MessageService.startService();
                obj.IsUIInitialized=true;
            end
        end

        function startService(obj)
            obj.initializeUI();
            obj.validateProfileTimer(obj.ProfileInterface.getProfileTimer());
            initialFunctionIndex=obj.DataModel.getSummaryFunctionIndex();
            obj.DataModel.setInitialFunctionIndex(initialFunctionIndex);
            profileViewerWindowCreationStatus=obj.showProfileViewerWindow;
            if~profileViewerWindowCreationStatus

                obj.MessageService.refreshProfiler;
            end
        end

        function startServiceFromInputFunction(obj,functionName,profInfoStaleStatus)
            obj.initializeUI();
            obj.validateProfileTimer(obj.ProfileInterface.getProfileTimer());
            functionIndex=obj.convertToFunctionIndex(functionName);
            obj.DataModel.setInitialFunctionIndex(functionIndex);
            profileViewerWindowCreationStatus=obj.showProfileViewerWindow;
            if~profileViewerWindowCreationStatus
                if profInfoStaleStatus||obj.DataModel.getDataPayloadStaleState()
                    obj.MessageService.refreshProfiler;
                else
                    obj.MessageService.broadcastFunctionIndex(obj.DataModel.getInitialFunctionIndex());
                end
            end
        end

        function openExistingOrFreshViewer(obj)
            obj.initializeUI();
            if obj.BrowserService.isProfilerWindowValid()&&obj.ImplManagerInstance.doesUIMatchCurrentProfilerType()
                obj.BrowserService.bringToFrontIfOpen();
            else
                obj.ProfileInterface.clear();
                obj.ProfileInterface.viewer();
            end
        end

        function close(obj)
            if~isempty(obj.BrowserService)
                obj.BrowserService.close();
            end
        end

        function status=isProfileInfoStale(obj,profileInfo)


            obj.validateProfileInfoInput(profileInfo);
            status=obj.DataModel.isProfileInfoStale(profileInfo);
        end

        function functionIndex=convertToFunctionIndex(obj,functionName)
            summaryPayload=obj.DataModel.getSummaryViewPayload();
            initialFunctionIndex=obj.DataModel.getSummaryFunctionIndex();
            functionIndex=matlab.internal.profileviewer.getFunctionIndexFromName(summaryPayload.FunctionTable,...
            functionName,initialFunctionIndex);
        end

        function notifyProfilerStart(obj)
            obj.ProfilerState.setLastAction("on");


            obj.DataModel.setProfileResumedState(false);

            obj.DataModel.setPayloadStaleState(true);
            obj.ProfilerState.setState(true);
            if obj.needsToNotifyUI("start")
                obj.MessageService.broadcastProfilerStateChanged;
            end
        end

        function notifyProfilerResume(obj)
            obj.ProfilerState.setLastAction("resume");

            obj.DataModel.setProfileResumedState(true);
            obj.DataModel.setPayloadStaleState(true);
            obj.ProfilerState.setState(true);
            if obj.needsToNotifyUI("resume")
                obj.MessageService.broadcastProfilerStateChanged;
            end
        end

        function notifyProfilerStop(obj,~)
            obj.ProfilerState.setLastAction("off");

            obj.ProfilerState.setState(false);
            if obj.needsToNotifyUI("stop")
                obj.MessageService.broadcastProfilerStateChanged;
            end
        end

        function notifyProfilerClear(obj)
            obj.ProfilerState.setLastAction("clear");


            obj.DataModel.setDataPayloadLoadState(false);
            initialFunctionIndex=obj.DataModel.getSummaryFunctionIndex();
            obj.DataModel.setInitialFunctionIndex(initialFunctionIndex);
            if obj.needsToNotifyUI("clear")

                obj.DataModel.setDataPayloadStaleState(true);
                obj.MessageService.refreshProfiler;
            else


                obj.DataModel.setPayloadStaleState(true);
            end
        end

        function notifyProfileViewer(obj)


            obj.ImplManagerInstance.setUIProfilerTypeToCurrent()


            if obj.DataModel.getPayloadStaleState()
                obj.DataModel.setPayloadStaleState(false);
                obj.DataModel.setDataPayloadStaleState(true);
            end
        end

        function setDebugMode(obj,debugMode)
            obj.initializeUI();
            obj.BrowserService.setDebugMode(debugMode);
        end

        function setLastRunAndTime(obj,expression,notifyOfStart)

            if obj.IsUIInitialized&&notifyOfStart
                obj.MessageService.broadcastRunAndTimeStart();
            end
            obj.DataModel.setLastRunAndTime(expression);
        end

        function setLastRunAndTimeError(obj,expression)

            obj.DataModel.setLastRunAndTimeError(expression);
        end

        function loadSavedProfileData(obj,profileInfo)

            obj.validateProfileInfoInput(profileInfo);


            obj.DataModel.setDataPayloadStaleState(false);
            obj.DataModel.setDataPayloadLoadState(true);
            obj.DataModel.loadData(profileInfo);
        end

        function clientId=getClientId(obj)
            obj.initializeUI();
            clientId=obj.ClientId;
        end

        function browserService=getBrowserService(obj)
            browserService=obj.BrowserService;
        end
    end

    methods(Access=protected)
        function obj=ProfileViewerService(implManager)
            obj@matlab.internal.profileviewer.ImplManagerClient(implManager);


            obj.ClientId=datestr(now,30);
        end

        function onImplSwapIn(obj)
            obj.DataModel=obj.ImplManagerInstance.getDataModelImpl();
            obj.ProfileInterface=obj.ImplManagerInstance.getProfileInterfaceImpl();
            obj.ProfilerState=obj.ImplManagerInstance.getProfilerState();
            obj.UINotificationPolicy=obj.ImplManagerInstance.getUINotificationPolicyImpl();
        end

        function onClientRegistration(obj)
            obj.DataModel=obj.ImplManagerInstance.getDataModelImpl();
            obj.ProfileInterface=obj.ImplManagerInstance.getProfileInterfaceImpl();
            obj.ProfilerState=obj.ImplManagerInstance.getProfilerState();
            obj.UINotificationPolicy=obj.ImplManagerInstance.getUINotificationPolicyImpl();
        end

        function profileViewerWindowCreationStatus=showProfileViewerWindow(obj)
            obj.initializeUI();
            profileViewerWindowCreationStatus=obj.BrowserService.getProfileViewerWindow;
        end

        function validateProfileInfoInput(~,profileInfo)

            validateattributes(profileInfo,{'struct'},{'nonempty'});

            if~isfield(profileInfo,{'FunctionTable'})
                error(message('MATLAB:profiler:InvalidInputArgument'));
            end
        end

        function validateProfileTimer(~,timer)

            if~timer
                error(message('MATLAB:profiler:UnsupportedInputArgument','CLOCK'));
            end
        end

        function out=needsToNotifyUI(obj,action)

            out=obj.ImplManagerInstance.CurrentProfilerType==obj.ImplManagerInstance.UIProfilerType&&...
            obj.IsUIInitialized&&obj.UINotificationPolicy(action);
        end
    end
end
