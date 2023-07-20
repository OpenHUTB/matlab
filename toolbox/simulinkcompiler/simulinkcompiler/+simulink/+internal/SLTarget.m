classdef(Abstract)SLTarget<simulink.internal.Target




    properties(Access=public)
ModelStatus
    end

    properties(SetAccess=protected,SetObservable)
ModelName
    end

    events
Pausing
PauseFailed
Paused
PostPaused

Resuming
ResumeFailed
Resumed
PostResumed

SimulationTimeChanged
    end

    methods
        function obj=SLTarget()
            obj.ModelStatus.State='';
            obj.ModelStatus.Application='';
            obj.ModelStatus.ExecTime=0;
        end

        function TF=isPaused(obj)
            simStatus=simulink.compiler.getSimulationStatus(obj.ModelName);
            TF=isequal(simStatus,slsim.SimulationStatus.Paused);
        end
    end
end
