classdef LockedResultRangesStrategy<SimulinkFixedPoint.WarningConditions.ResultRangesStrategy










    methods(Access=public)

        function this=LockedResultRangesStrategy(result)


            this=this@SimulinkFixedPoint.WarningConditions.ResultRangesStrategy(result);
        end
        function getContainerInfo(this,result)

            this.containerInfo=result.getSpecifiedDTContainerInfo();
        end

    end

end