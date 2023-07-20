classdef CheckGroupSignedness<SimulinkFixedPoint.WarningConditions.AbstractCondition


















    methods(Access=public)
        function this=CheckGroupSignedness()
            this.messageID={
'FixedPointTool:fixedPointTool:alertNegWithUnsignedSharedSim'
'FixedPointTool:fixedPointTool:alertNegWithUnsignedSharedDerived'
'FixedPointTool:fixedPointTool:alertNegWithUnsignedSharedDesign'
'FixedPointTool:fixedPointTool:alertNegWithUnsignedSharedModelRequired'
            };
        end

        function flag=check(~,~,group)


            groupStrategy=SimulinkFixedPoint.WarningConditions.GroupRangesStrategy(group);



            signednessCondition=SimulinkFixedPoint.WarningConditions.SignednessInterface(groupStrategy);


            flag=signednessCondition.performCheck(group);

        end

    end

end
