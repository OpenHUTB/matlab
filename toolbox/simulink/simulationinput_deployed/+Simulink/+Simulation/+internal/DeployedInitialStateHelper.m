classdef DeployedInitialStateHelper<Simulink.Simulation.internal.InitialStateHelper




    properties
        EmptyOperatingPoint=Simulink.op.ModelOperatingPoint.empty()
    end

    methods(Static)




        function validate(initialState)
            if isequal([],initialState)||...
                isequal(initialState,Simulink.op.ModelOperatingPoint.empty())




                return;
            end

            if isnumeric(initialState)
                validateattributes(initialState,...
                {'numeric'},{'vector'});
            else
                validateattributes(initialState,...
                {'Simulink.op.ModelOperatingPoint',...
                'Simulink.SimulationData.Dataset',...
                'struct'},{'scalar'});
            end
        end
    end
end
