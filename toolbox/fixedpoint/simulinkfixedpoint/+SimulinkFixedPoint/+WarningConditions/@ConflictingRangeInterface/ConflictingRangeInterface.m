classdef ConflictingRangeInterface<SimulinkFixedPoint.WarningConditions.RangeConditionsInterface











    methods(Access=public)
        function this=ConflictingRangeInterface(rangesStrategy)
            this.rangesStrategy=rangesStrategy;
        end
    end

    methods(Access=public)
        function rangesWithIssues=checkCondition(~,rangesMin,rangesMax,containerInfo)



            rangesWithIssues=false(length(rangesMin),1);
            for rangeIndex=1:length(rangesMin)
                rangesWithIssues(rangeIndex)=...
                ~SimulinkFixedPoint.AutoscalerAlertsUtil.checkRange(rangesMin{rangeIndex},containerInfo.min,containerInfo.max,containerInfo.evaluatedNumericType)||...
                ~SimulinkFixedPoint.AutoscalerAlertsUtil.checkRange(rangesMax{rangeIndex},containerInfo.min,containerInfo.max,containerInfo.evaluatedNumericType);
            end
        end
    end
end

