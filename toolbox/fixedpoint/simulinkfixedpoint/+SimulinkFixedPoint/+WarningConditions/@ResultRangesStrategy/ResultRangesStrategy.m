classdef ResultRangesStrategy<SimulinkFixedPoint.WarningConditions.RangeStrategy






    methods(Access=public)

        function this=ResultRangesStrategy(result)

            this=this@SimulinkFixedPoint.WarningConditions.RangeStrategy(result);
        end
        function getContainerInfo(this,result)

            this.containerInfo=result.getProposedDTContainerInfo();
        end

        function[rangesMin,rangesMax]=getRanges(~,result)

            rangesMin{1}=result.SimMin;
            rangesMax{1}=result.SimMax;
            rangesMin{2}=result.DerivedMin;
            rangesMax{2}=result.DerivedMax;
            rangesMin{3}=result.DesignMin;
            rangesMax{3}=result.DesignMax;
            rangesMin{4}=result.ModelRequiredMin;
            rangesMax{4}=result.ModelRequiredMax;
        end
    end

end
