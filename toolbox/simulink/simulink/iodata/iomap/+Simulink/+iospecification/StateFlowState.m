classdef StateFlowState<Simulink.iospecification.LoggedSignalInput





    methods(Static)
        function bool=isa(varIn)
            bool=isa(varIn,'Stateflow.SimulationData.State');
        end

    end


    methods

        function obj=StateFlowState(name,value)

            obj=obj@Simulink.iospecification.LoggedSignalInput(name,value);
            obj.SupportedVarType='stateflow state';

        end
    end


    methods(Access='protected')


        function bool=isValidInputForm(~,varIn)
            bool=Simulink.iospecification.StateFlowState.isa(varIn);
        end
    end

end
