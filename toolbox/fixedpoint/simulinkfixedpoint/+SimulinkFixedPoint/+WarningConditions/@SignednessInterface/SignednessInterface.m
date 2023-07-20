classdef SignednessInterface<SimulinkFixedPoint.WarningConditions.RangeConditionsInterface









    methods(Access=public)
        function this=SignednessInterface(rangesStrategy)
            this.rangesStrategy=rangesStrategy;
        end
    end

    methods(Access=public)
        function signednessHaveIssues=checkCondition(~,rangesMin,rangesMax,containerInfo)


            signednessHaveIssues=false(length(rangesMin),1);
            for rangeIndex=1:length(rangesMin)
                signednessHaveIssues(rangeIndex)=...
                ~(SimulinkFixedPoint.AutoscalerAlertsUtil.checkNegOK(rangesMin{rangeIndex},containerInfo)&&...
                SimulinkFixedPoint.AutoscalerAlertsUtil.checkNegOK(rangesMax{rangeIndex},containerInfo));
            end

        end
    end
end

