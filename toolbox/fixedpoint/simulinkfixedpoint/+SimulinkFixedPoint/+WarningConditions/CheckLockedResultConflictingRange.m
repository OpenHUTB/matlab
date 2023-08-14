classdef CheckLockedResultConflictingRange<SimulinkFixedPoint.WarningConditions.AbstractCondition















    methods(Access=public)
        function this=CheckLockedResultConflictingRange()
            this.messageID={
'FixedPointTool:fixedPointTool:alertExceedsSpecRangeSim'
'FixedPointTool:fixedPointTool:alertExceedsSpecRangeDerived'
'FixedPointTool:fixedPointTool:alertExceedsSpecRangeDesign'
            'FixedPointTool:fixedPointTool:alertExceedsSpecRangeModelRequired'};
        end
        function flags=check(this,result,~)
            flags=false(length(this.messageID),1);


            if result.isLocked



                lockedResultStrategy=SimulinkFixedPoint.WarningConditions.LockedResultRangesStrategy(result);



                conflictingRangeCondition=SimulinkFixedPoint.WarningConditions.ConflictingRangeInterface(lockedResultStrategy);


                flags=conflictingRangeCondition.performCheck(result);
            end
        end

    end
end
