classdef CheckLockedResultGroupConflictingRange<SimulinkFixedPoint.WarningConditions.AbstractCondition
















    methods(Access=public)
        function this=CheckLockedResultGroupConflictingRange()
            this.messageID={
'FixedPointTool:fixedPointTool:alertExceedsSpecRangeSharedSim'
'FixedPointTool:fixedPointTool:alertExceedsSpecRangeSharedDerived'
'FixedPointTool:fixedPointTool:alertExceedsSpecRangeSharedDesign'
            'FixedPointTool:fixedPointTool:alertExceedsSpecRangeSharedModelRequired'};
        end
        function flags=check(this,result,group)
            flags=false(length(this.messageID),1);


            if result.isLocked



                lockedResultStrategy=SimulinkFixedPoint.WarningConditions.LockedResultGroupRangesStrategy(result);



                conflictingRangeCondition=SimulinkFixedPoint.WarningConditions.ConflictingRangeInterface(lockedResultStrategy);



                flags=conflictingRangeCondition.performCheck(group);
            end
        end

    end

end
