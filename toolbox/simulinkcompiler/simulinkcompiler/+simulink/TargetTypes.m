classdef TargetTypes




    properties(SetAccess=immutable)
Value
    end

    methods
        function obj=TargetTypes(value)
            obj.Value=value;
        end
    end

    enumeration
        SL_SIMULATION_TARGET('SL:SimulationTarget')
        SLRT_SIMULINK_NORMAL_MODE('SLRT:SimulinkNormalMode')
        SLRT_SPEEDGOAT('SLRT:SpeedGoat')
    end
end
