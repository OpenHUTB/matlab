classdef DesktopInitialStateHelper<Simulink.Simulation.internal.InitialStateHelper
    properties
        EmptyOperatingPoint=Simulink.op.ModelOperatingPoint.empty()
    end

    methods(Static)




        function validate(initialState)
            if isequal([],initialState)||...
                isequal(initialState,Simulink.op.ModelOperatingPoint.empty())




                return;
            end

            stateClass=class(initialState);
            if(isequal(stateClass,'Simulink.op.ModelOperatingPoint')||...
                isequal(stateClass,'Simulink.SimulationData.Dataset'))


                validateattributes(initialState,{stateClass},{'scalar'});
            end

            validateattributes(initialState,...
            {'Simulink.op.ModelOperatingPoint',...
            'Simulink.SimulationData.Dataset',...
            'struct','numeric','logical'},{'vector'});
        end
    end
end