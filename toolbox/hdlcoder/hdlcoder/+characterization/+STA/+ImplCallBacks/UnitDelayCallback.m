
classdef UnitDelayCallback<characterization.STA.ImplementationCallback





    methods
        function self=UnitDelayCallback()
            self@characterization.STA.ImplementationCallback();
        end

        function preprocessModelDependentParams(~,modelInfo)
            set_param(modelInfo.blockPath,'SampleTime','-1');
        end

    end

end
