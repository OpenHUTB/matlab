classdef JobStatusDBConfig<handle
    properties
        DrawNowThrottler(1,1)MultiSim.internal.FunctionCallThrottler=MultiSim.internal.FunctionCallThrottler(@drawnow,1)
        FunctionCallThrottler(1,1)function_handle=@MultiSim.internal.FunctionCallThrottler
    end
end