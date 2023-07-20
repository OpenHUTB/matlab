classdef DeployedModelParameterHelper<Simulink.Simulation.internal.ModelParameterHelper
    methods(Static)
        function TF=isReadOnly(~)
            TF=false;
        end

        function TF=isValidParam(~,~)
            TF=true;
        end
    end
end
