classdef CheckResultConflictingRange<SimulinkFixedPoint.WarningConditions.AbstractCondition















    methods(Access=public)

        function this=CheckResultConflictingRange()
            this.messageID={
'FixedPointTool:fixedPointTool:alertExceedsRepRangeSim'
'FixedPointTool:fixedPointTool:alertExceedsRepRangeDerived'
'FixedPointTool:fixedPointTool:alertExceedsRepRangeDesign'
            'FixedPointTool:fixedPointTool:alertExceedsRepRangeModelRequired'};
        end
        function flags=check(~,result,~)


            resultStrategy=SimulinkFixedPoint.WarningConditions.ResultRangesStrategy(result);



            conflictingRangeCondition=SimulinkFixedPoint.WarningConditions.ConflictingRangeInterface(resultStrategy);


            flags=conflictingRangeCondition.performCheck(result);

        end

    end

end
