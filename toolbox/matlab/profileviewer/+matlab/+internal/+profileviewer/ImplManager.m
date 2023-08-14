classdef ImplManager<handle







    properties(SetAccess=private)
CurrentProfilerType

UIProfilerType
    end

    properties(Access=private)
DataModelImpls
ProfileInterfaceImpls
RequestDispatcherImpls
ProfilerState
UINotificationPolicyImpls
RegisteredImpls
ClientList
    end

    methods
        function obj=ImplManager()
            obj.CurrentProfilerType=matlab.internal.profileviewer.ProfilerType.NONE;
            obj.DataModelImpls=containers.Map();
            obj.ProfileInterfaceImpls=containers.Map();
            obj.RequestDispatcherImpls=containers.Map();
            obj.ProfilerState=containers.Map();
            obj.UINotificationPolicyImpls=containers.Map();
            obj.RegisteredImpls=matlab.internal.profileviewer.ProfilerType.empty();
            obj.UIProfilerType=matlab.internal.profileviewer.ProfilerType.NONE;
            obj.ClientList=struct('client',{},...
            'swapInCallback',{},...
            'swapOutCallback',{},...
            'registerCallback',{});
            mlock;
        end
    end

    methods
        function setCurrentImpl(obj,profilerType)
            if profilerType==obj.CurrentProfilerType
                return;
            end
            if~ismember(profilerType,obj.RegisteredImpls)
                obj.createImplInstances(profilerType);
            end

            isSwapping=obj.CurrentProfilerType~=matlab.internal.profileviewer.ProfilerType.NONE;
            if isSwapping
                obj.callClientsOnSwapOutCallbacks();
            end
            obj.CurrentProfilerType=profilerType;
            if isSwapping
                obj.callClientsOnSwapInCallbacks();
            end
        end

        function setUIProfilerTypeToCurrent(obj)
            obj.UIProfilerType=obj.CurrentProfilerType;
        end

        function flag=doesUIMatchCurrentProfilerType(obj)
            flag=obj.UIProfilerType==obj.CurrentProfilerType;
        end

        function registerClient(obj,client,swapInCallback,swapOutCallback,registerCallback)


            assert(isa(client,'matlab.internal.profileviewer.ImplManagerClient'));
            clientStruct=struct('client',client,...
            'swapInCallback',swapInCallback,...
            'swapOutCallback',swapOutCallback,...
            'registerCallback',registerCallback);
            obj.ClientList(end+1)=clientStruct;
            clientStruct.registerCallback();
        end

        function profileInterface=getProfileInterfaceImpl(obj)
            implKey=char(obj.CurrentProfilerType);
            profileInterface=obj.ProfileInterfaceImpls(implKey);
        end

        function dataModel=getDataModelImpl(obj)
            implKey=char(obj.CurrentProfilerType);
            dataModel=obj.DataModelImpls(implKey);
        end

        function requestDispatcher=getRequestDispatcherImpl(obj)
            implKey=char(obj.CurrentProfilerType);
            requestDispatcher=obj.RequestDispatcherImpls(implKey);
        end

        function uINotificationPolicy=getUINotificationPolicyImpl(obj)
            implKey=char(obj.CurrentProfilerType);
            uINotificationPolicy=obj.UINotificationPolicyImpls(implKey);
        end

        function state=getProfilerState(obj)
            implKey=char(obj.CurrentProfilerType);
            state=obj.ProfilerState(implKey);
        end

        function allProfileInterfaces=getAllProfileInterfaceImpl(obj)
            allProfileInterfaces=obj.ProfileInterfaceImpls;
        end

        function allDataModels=getAllDataModelImpl(obj)
            allDataModels=obj.DataModelImpls;
        end

        function allRequestDispatchers=getAllRequestDispatcherImpl(obj)
            allRequestDispatchers=obj.RequestDispatcherImpls;
        end

        function allStates=getAllProfilerState(obj)
            allStates=obj.ProfilerState;
        end
    end

    methods(Access=protected,Hidden)
        function createImplInstances(obj,profilerType)

            implKey=char(profilerType);
            switch profilerType
            case matlab.internal.profileviewer.ProfilerType.MATLAB
                obj.ProfileInterfaceImpls(implKey)=matlab.internal.profileviewer.model.MatlabProfileInterface();
                obj.DataModelImpls(implKey)=matlab.internal.profileviewer.model.MatlabDataModel(obj.ProfileInterfaceImpls(implKey));
                obj.ProfilerState(implKey)=matlab.internal.profileviewer.ProfilerState(obj.ProfileInterfaceImpls(implKey));
                obj.RequestDispatcherImpls(implKey)=matlab.internal.profileviewer.MatlabRequestDispatcher(obj.DataModelImpls(implKey),obj.ProfilerState(implKey));
                obj.UINotificationPolicyImpls(implKey)=@matlab.internal.profileviewer.getMatlabUINotificationPolicy;
            case matlab.internal.profileviewer.ProfilerType.MPI
                assert(matlab.internal.parallel.isPCTInstalled,message('MATLAB:profiler:ViewerImplementationNotFound','MPI'));
                obj.ProfileInterfaceImpls(implKey)=parallel.internal.profileviewer.model.MpiProfileInterface();
                obj.DataModelImpls(implKey)=parallel.internal.profileviewer.model.MpiDataModel(obj.ProfileInterfaceImpls(implKey));
                obj.ProfilerState(implKey)=matlab.internal.profileviewer.ProfilerState(obj.ProfileInterfaceImpls(implKey));
                obj.RequestDispatcherImpls(implKey)=parallel.internal.profileviewer.MpiRequestDispatcher(obj.DataModelImpls(implKey),obj.ProfilerState(implKey));
                obj.UINotificationPolicyImpls(implKey)=@parallel.internal.profileviewer.getMpiUINotificationPolicy;
            otherwise
                error(message('MATLAB:profiler:InvalidProfilerType',implKey));
            end

            dataModel=obj.DataModelImpls(implKey);
            dataModel.setDataPayloadStaleState(true);
            obj.RegisteredImpls(end+1)=profilerType;
        end

        function callClientsOnSwapOutCallbacks(obj)
            for client=obj.ClientList
                client.swapOutCallback();
            end
        end

        function callClientsOnSwapInCallbacks(obj)
            for client=obj.ClientList
                client.swapInCallback();
            end
        end
    end
end
