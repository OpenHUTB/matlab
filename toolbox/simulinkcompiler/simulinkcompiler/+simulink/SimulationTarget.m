classdef SimulationTarget<simulink.internal.SLTarget




    properties
SimulationCompletedFcn
        StopTime=10.0
    end

    properties(SetObservable)
        SimulationInput Simulink.SimulationInput
    end

    properties(SetAccess=protected)
        SimulationOutput Simulink.SimulationOutput
SimulationErrors
    end

    properties(Access=protected)
        Initialized=false
    end

    properties(Access=private)
        notifiedStarted=false
    end

    methods
        function obj=SimulationTarget(modelName)
            obj=obj@simulink.internal.SLTarget();
            if isempty(modelName)
                obj.TargetSettings.name=simulink.TargetTypes.SL_SIMULATION_TARGET.Value;
                return;
            end
            obj.initialize(modelName);
            obj.connect();
        end
    end

    methods(Access=public,Static)
        function obj=getDefaultSimulationTarget()
            obj=simulink.SimulationTarget('');
        end
    end

    methods(Access=public)
        function isEmpty=isTargetEmpty(obj)
            isEmpty=false;



            if isempty(obj.ModelName)&&...
                isempty(obj.SimulationInput)
                isEmpty=true;
            end
        end
    end

    methods(Access=protected)

        function initialize(obj,modelName)
            if obj.Initialized&&isequal(modelName,obj.ModelName)
                return;
            end

            addlistener(obj,'SimulationInput','PostSet',@obj.updateModel);
            obj.TargetSettings.name=simulink.TargetTypes.SL_SIMULATION_TARGET.Value;
            obj.SimulationInput=simulink.compiler.internal.getDefaultSimulationInput(modelName);
            obj.Initialized=true;
        end
    end

    methods
        function targetHandle=connect(obj)
            targetHandle=obj;

            if obj.isConnected(),return;end

            notify(obj,'Connecting');

            simIn=obj.SimulationInput;
            simIn=simulink.compiler.configureForDeployment(simIn);
            obj.SimulationInput=simIn;

            obj.connected=true;

            notify(obj,'Connected');
            notify(obj,'PostConnected');
        end

        function disconnect(obj)
            obj.connected=false;
        end

        function start(obj,varargin)
            obj.connect();
            obj.notifiedStarted=false;

            si=obj.SimulationInput;
            paramNames=string({si.ModelParameters.Name});

            if~isempty(si.ModelParameters)&&...
                ismember('StopTime',paramNames)

                stopTimeParam=si.ModelParameters(paramNames=='StopTime');
                stopTimeStr=stopTimeParam.Value;
                obj.StopTime=eval(stopTimeParam.Value);
            else
                if isdeployed
                    stopTimeStr=num2str(obj.StopTime);
                    warning(message('simulinkcompiler:simulink_components:UsingDefaultStopTime').getString());
                else
                    stopTimeStr=get_param(obj.ModelName,'StopTime');
                    obj.StopTime=eval(stopTimeStr);
                end
            end
            obj.SimulationInput=si.setModelParameter('StopTime',stopTimeStr);

            obj.tcTimer=timer('ExecutionMode','fixedSpacing',...
            'Period',0.1,'TimerFcn',@(o,e)obj.timerCallback);

            obj.tcTimer.start;

            try

                obj.SimulationOutput=sim(obj.SimulationInput);

                obj.announceSimTime();
                obj.clearTCTimer();

                if~isempty(obj.SimulationCompletedFcn)
                    obj.SimulationCompletedFcn(obj.SimulationOutput);
                end

            catch ME
                obj.clearTCTimer();
                obj.SimulationErrors=ME;
                notify(obj,'StartFailed');



            end

            notify(obj,'Stopped');
            notify(obj,'PostStopped');
        end

        function pause(obj)
            notify(obj,'Pausing');
            simulink.compiler.pauseSimulation(obj.ModelName);
            notify(obj,'Paused');
        end

        function resume(obj)
            notify(obj,'Resuming');
            simulink.compiler.resumeSimulation(obj.ModelName);
            notify(obj,'Resumed');
        end

        function stop(obj)
            if obj.isRunning()||obj.isPaused()
                simulink.compiler.stopSimulation(obj.ModelName);
            end
        end

        function TF=isConnected(obj)
            TF=obj.connected;
        end

        function load(this,modelName,varargin)%#ok<INUSD> 

        end

        function[TF,loadedAppName]=isLoaded(obj,appName)
            if nargin<2
                appName=[];
            end

            if isempty(appName)
                TF=~isempty(obj.ModelName);
                loadedAppName=obj.ModelName;
            else
                TF=strcmp(obj.ModelName,appName);
                loadedAppName=appName;
            end
        end

        function[TF,runningAppName]=isRunning(obj,appName)
            if nargin<2
                appName=[];
            end

            simStatus=simulink.compiler.getSimulationStatus(obj.ModelName);
            simRunning=isequal(simStatus,slsim.SimulationStatus.Running);

            if~obj.isLoaded()
                TF=false;
                runningAppName=[];
            else
                if isempty(appName)
                    TF=simRunning;
                    runningAppName=obj.ModelName;
                else
                    if~strcmp(obj.ModelName,appName)
                        TF=false;
                        runningAppName=[];
                    else
                        TF=simRunning;
                        runningAppName=obj.ModelName;
                    end
                end
            end
        end

        function TF=isStopped(obj)
            simStatus=simulink.compiler.getSimulationStatus(obj.ModelName);
            TF=isequal(simStatus,slsim.SimulationStatus.Stopped);
        end

        function TF=isPaused(obj)
            simStatus=simulink.compiler.getSimulationStatus(obj.ModelName);
            TF=isequal(simStatus,slsim.SimulationStatus.Paused);
        end

        function TF=isInactive(obj)
            simStatus=simulink.compiler.getSimulationStatus(obj.ModelName);
            TF=isequal(simStatus,slsim.SimulationStatus.Inactive);
        end

        function setStopTime(this,stopTime)%#ok<INUSD>

        end

        function isRunning=isSimulationRunning(obj)
            status=simulink.compiler.getSimulationStatus(obj.ModelName);
            isRunning=(status==slsim.SimulationStatus.Running);
        end

        function isPaused=isSimulationPaused(obj)
            status=simulink.compiler.getSimulationStatus(obj.ModelName);
            isPaused=(status==slsim.SimulationStatus.Paused);
        end

        function delete(obj)
            obj.clearTCTimer();
        end
    end

    methods(Access=private)
        function updateModel(obj,~,~)
            obj.ModelName=obj.SimulationInput.ModelName;
        end

        function timerCallback(obj)
            simStatus=simulink.compiler.getSimulationStatus(obj.ModelName);
            simRunning=isequal(simStatus,slsim.SimulationStatus.Running);
            simPaused=isequal(simStatus,slsim.SimulationStatus.Paused);

            if simRunning&&...
                ~obj.notifiedStarted
                notify(obj,'Started');
                notify(obj,'PostStarted');

                obj.ModelStatus.State='RUNNING';
                obj.notifiedStarted=true;
            end

            if~simPaused
                obj.announceSimTime();
            end
        end

        function clearTCTimer(obj)
            if isempty(obj.tcTimer),return;end

            obj.tcTimer.stop;
            delete(obj.tcTimer);
            obj.tcTimer=[];
        end

        function announceSimTime(obj)
            if isfinite(obj.StopTime)
                simTime=simulink.compiler.getSimulationTime(...
                obj.ModelName);
            else
                simTime=-1;
            end

            evtData=simulink.internal.SimTimeEventData(simTime);
            notify(obj,'SimulationTimeChanged',evtData);
        end
    end

end
