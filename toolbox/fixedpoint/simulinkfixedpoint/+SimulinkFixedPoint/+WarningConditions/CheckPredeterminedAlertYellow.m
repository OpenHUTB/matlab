classdef CheckPredeterminedAlertYellow<SimulinkFixedPoint.WarningConditions.AbstractCondition
















    methods

        function flag=check(~,result,~)


            flag=strcmp(result.getAlert,'yellow');
        end

        function warningString=getWarning(~,~,~)



            warningString={};
        end
    end
end
