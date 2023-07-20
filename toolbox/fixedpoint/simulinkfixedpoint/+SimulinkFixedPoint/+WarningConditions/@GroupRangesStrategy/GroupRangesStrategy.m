classdef GroupRangesStrategy<SimulinkFixedPoint.WarningConditions.RangeStrategy






    methods(Access=public)
        function this=GroupRangesStrategy(group)


            this=this@SimulinkFixedPoint.WarningConditions.RangeStrategy(group);
        end
        function getContainerInfo(this,group)


            this.containerInfo=group.finalProposedDataType;
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