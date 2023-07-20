classdef CheckPredeterminedAlertRed<SimulinkFixedPoint.WarningConditions.AbstractCondition
















    methods
        function this=CheckPredeterminedAlertRed()
            this.messageID={'SimulinkFixedPoint:autoscaling:sharedGroupWarningPropagation'};
        end
        function flag=check(~,result,~)



            flag=strcmp(result.getAlert,'red');
        end

        function warningString=getWarning(this,result,~)
            if this.check(result,[])&&result.hasDTGroup



                warningString={getString(message(this.messageID{1},result.getDTGroup))};
            else


                warningString={};
            end
        end
    end
end


