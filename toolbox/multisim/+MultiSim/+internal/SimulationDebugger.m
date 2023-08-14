




classdef(Abstract)SimulationDebugger<handle
    properties(Dependent)
ModelName
    end

    properties(SetAccess=protected)
ModelHandle
DebugRunId
        IsConnected=false
    end

    properties(Access=protected)
SignalSelectionListener
SigSelector
    end

    methods
        function obj=SimulationDebugger(modelName)
            load_system(modelName);
            obj.ModelHandle=get_param(modelName,'Handle');
            obj.createSignalSelector(modelName);
        end

        function modelName=get.ModelName(obj)
            modelName=get_param(obj.ModelHandle,'Name');
        end
    end

    methods(Abstract)
        connect(obj,runId)
        pause(obj)
        forward(obj)
        resume(obj)
        stop(obj)
    end

    methods
        function disconnect(obj)
            obj.IsConnected=false;
            obj.resume();
        end
    end

    methods(Hidden=true)
        execute(obj,fh)
    end

    methods
        function enableSignalSelectionChangeEvent(obj)
            obj.SignalSelectionListener=addlistener(obj.SigSelector,...
            'ItemsChanged',@obj.handleSignalSelection);
        end
    end

    methods(Access=private)
        function createSignalSelector(obj,modelName)
            opt=Simulink.sigselector.Options;
            opt.Model=modelName;
            opt.InteractiveSelection=true;
            obj.SigSelector=Simulink.sigselector.SigSelectorTC(opt);
        end
    end

    methods(Abstract)
        handleSignalSelection(obj,eventSrc,eventData)
    end

    methods(Static)
        function out=debugLog(status)


            persistent DebugLogVal
            if nargin
                DebugLogVal=status;
            end
            out=DebugLogVal;
        end
    end
end
