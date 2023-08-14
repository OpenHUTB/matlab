classdef CheckGroupConflictingRange<SimulinkFixedPoint.WarningConditions.AbstractCondition
















    methods(Access=public)
        function this=CheckGroupConflictingRange()
            this.messageID={
'FixedPointTool:fixedPointTool:alertExceedsRepRangeSharedSim'
'FixedPointTool:fixedPointTool:alertExceedsRepRangeSharedDerived'
'FixedPointTool:fixedPointTool:alertExceedsRepRangeSharedDesign'
'FixedPointTool:fixedPointTool:alertExceedsRepRangeSharedModelRequired'
            };
        end

        function flag=check(~,~,group)


            groupStrategy=SimulinkFixedPoint.WarningConditions.GroupRangesStrategy(group);



            conflictingRangeCondition=SimulinkFixedPoint.WarningConditions.ConflictingRangeInterface(groupStrategy);


            flag=conflictingRangeCondition.performCheck(group);

        end

    end

end
