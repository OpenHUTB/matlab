
classdef UnitDelayResettableCallback<characterization.STA.ImplementationCallback





    methods
        function self=UnitDelayResettableCallback()
            self@characterization.STA.ImplementationCallback();
        end

        function preprocessModelDependentParams(~,modelInfo)

        end

        function preprocessWidthSettings(~,modelInfo)
            value={characterization.ParamDesc.SIMULINK_PARAM,'boolean'};
            modelInfo.wmap(2)=value;
        end

    end

end
