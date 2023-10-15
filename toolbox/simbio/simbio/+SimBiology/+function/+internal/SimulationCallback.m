classdef SimulationCallback < handle
    methods ( Access = private )
        function obj = SimulationCallback(  )
        end
    end
    properties ( Constant, Access = private )
        Instance = SimBiology.function.internal.SimulationCallback(  )
    end
    properties
        CallbackFcn
    end
    methods ( Static )
        function clear(  )
            instance = SimBiology.function.internal.SimulationCallback.Instance;
            instance.CallbackFcn = [  ];
        end
        function set( fcn )
            arguments
                fcn function_handle
            end
            instance = SimBiology.function.internal.SimulationCallback.Instance;
            instance.CallbackFcn = fcn;
        end
        function fcn = get(  )
            instance = SimBiology.function.internal.SimulationCallback.Instance;
            fcn = instance.CallbackFcn;
        end
    end
end

