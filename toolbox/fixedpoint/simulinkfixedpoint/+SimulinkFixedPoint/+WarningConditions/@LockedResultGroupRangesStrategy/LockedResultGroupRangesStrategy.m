classdef LockedResultGroupRangesStrategy<SimulinkFixedPoint.WarningConditions.ResultRangesStrategy












    methods(Access=public)

        function this=LockedResultGroupRangesStrategy(result)


            this=this@SimulinkFixedPoint.WarningConditions.ResultRangesStrategy(result);
        end

        function getContainerInfo(this,result)


            this.containerInfo=result.getSpecifiedDTContainerInfo();
        end

        function[rangesMin,rangesMax]=getRanges(~,group)



            rangeTypes=SimulinkFixedPoint.AutoscalerAlertsUtil.getRangeTypesForWarnings();


            rangesMin=cell(length(rangeTypes),1);
            rangesMax=cell(length(rangeTypes),1);
            for rangeIndex=1:length(rangeTypes)
                rangesMin{rangeIndex}=group.ranges{fxptds.RangeType.getIndex(rangeTypes{rangeIndex})}.minExtremum;
                rangesMax{rangeIndex}=group.ranges{fxptds.RangeType.getIndex(rangeTypes{rangeIndex})}.maxExtremum;
            end
        end

    end

end