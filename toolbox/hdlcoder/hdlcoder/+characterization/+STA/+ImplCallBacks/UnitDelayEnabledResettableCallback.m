
classdef UnitDelayEnabledResettableCallback<characterization.STA.ImplementationCallback





    methods
        function self=UnitDelayEnabledResettableCallback()
            self@characterization.STA.ImplementationCallback();
        end

        function preprocessModelDependentParams(~,modelInfo)

        end

        function preprocessWidthSettings(~,modelInfo)
            value={characterization.ParamDesc.SIMULINK_PARAM,'boolean'};
            modelInfo.wmap(2)=value;
            value={characterization.ParamDesc.SIMULINK_PARAM,'boolean'};
            modelInfo.wmap(3)=value;
        end

    end

end
