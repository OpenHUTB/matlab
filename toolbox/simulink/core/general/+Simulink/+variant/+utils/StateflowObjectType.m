classdef StateflowObjectType<uint8








    enumeration
        UNKNOWN(0)
        CHART(1)
        ATOMIC_SUBCHART(2)
        SIMULINK_FUNCTION(3)
        SIMULINK_STATE(4)
    end

    methods
        function objType=getType(obj)
            switch obj
            case Simulink.variant.utils.StateflowObjectType.CHART
                objType='Stateflow.Chart';
            case Simulink.variant.utils.StateflowObjectType.ATOMIC_SUBCHART
                objType='Stateflow.AtomicSubchart';
            case Simulink.variant.utils.StateflowObjectType.SIMULINK_FUNCTION
                objType='Stateflow.SLFunction';
            case Simulink.variant.utils.StateflowObjectType.SIMULINK_STATE
                objType='Stateflow.SimulinkBasedState';
            otherwise
                Simulink.variant.reducer.utils.assert(true,'Invalid Stateflow object type detected');
            end
        end
    end
end