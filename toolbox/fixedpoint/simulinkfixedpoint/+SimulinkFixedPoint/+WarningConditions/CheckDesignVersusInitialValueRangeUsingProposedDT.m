classdef CheckDesignVersusInitialValueRangeUsingProposedDT<SimulinkFixedPoint.WarningConditions.AbstractCondition






    methods

        function this=CheckDesignVersusInitialValueRangeUsingProposedDT()
            this.messageID={'FixedPointTool:fixedPointTool:alertInitValueRangeExceedsDesignRangeUsingProposedDT'};
        end

        function flag=check(~,result,~)


            flag=false;


            containerInfo=result.getProposedDTContainerInfo();



            if~isempty(containerInfo)
                flag=...
                ~SimulinkFixedPoint.AutoscalerAlertsUtil.checkDesignRangeWithEps(result.ModelRequiredMax,result.DesignMin,result.DesignMax,containerInfo.evaluatedNumericType)||...
                ~SimulinkFixedPoint.AutoscalerAlertsUtil.checkDesignRangeWithEps(result.ModelRequiredMin,result.DesignMin,result.DesignMax,containerInfo.evaluatedNumericType);
            end

        end
    end
end


