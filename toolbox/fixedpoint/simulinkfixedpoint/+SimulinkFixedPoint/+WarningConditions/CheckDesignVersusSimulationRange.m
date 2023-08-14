classdef CheckDesignVersusSimulationRange<SimulinkFixedPoint.WarningConditions.AbstractCondition






    methods

        function this=CheckDesignVersusSimulationRange()
            this.messageID={'FixedPointTool:fixedPointTool:alertSimRangeExceedsDesignRange'};
        end

        function flag=check(~,result,~)



            flag=false;




            if(result.hasCompiledDT())

                containerInfo=SimulinkFixedPoint.DTContainerInfo(result.getCompiledDT(),[]);



                flag=...
                ~SimulinkFixedPoint.AutoscalerAlertsUtil.checkDesignRangeWithEps(result.SimMax,result.DesignMin,result.DesignMax,containerInfo.evaluatedNumericType)||...
                ~SimulinkFixedPoint.AutoscalerAlertsUtil.checkDesignRangeWithEps(result.SimMin,result.DesignMin,result.DesignMax,containerInfo.evaluatedNumericType);
            end
        end
    end
end


