classdef CheckDesignVersusInitialValueRange<SimulinkFixedPoint.WarningConditions.AbstractCondition








    methods

        function this=CheckDesignVersusInitialValueRange()
            this.messageID={'FixedPointTool:fixedPointTool:alertInitValueRangeExceedsDesignRange'};
        end

        function flag=check(~,result,~)


            flag=~SimulinkFixedPoint.AutoscalerAlertsUtil.isExpectedBigSmallOrder(result.DesignMax,result.ModelRequiredMax)||...
            ~SimulinkFixedPoint.AutoscalerAlertsUtil.isExpectedBigSmallOrder(result.ModelRequiredMin,result.DesignMin);

        end
    end
end


