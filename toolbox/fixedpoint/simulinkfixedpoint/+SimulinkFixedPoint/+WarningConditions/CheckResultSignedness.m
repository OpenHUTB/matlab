classdef CheckResultSignedness<SimulinkFixedPoint.WarningConditions.AbstractCondition

















    methods(Access=public)
        function this=CheckResultSignedness()
            this.messageID={
'FixedPointTool:fixedPointTool:alertNegWithUnsignedSim'
'FixedPointTool:fixedPointTool:alertNegWithUnsignedDerived'
'FixedPointTool:fixedPointTool:alertNegWithUnsignedDesign'
'FixedPointTool:fixedPointTool:alertNegWithUnsignedModelRequired'
            };
        end
        function flag=check(~,result,~)


            resultStrategy=SimulinkFixedPoint.WarningConditions.ResultRangesStrategy(result);



            signednessCondition=SimulinkFixedPoint.WarningConditions.SignednessInterface(resultStrategy);


            flag=signednessCondition.performCheck(result);

        end

    end
end
