classdef MultiTabularYLimitsStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.YLimitsStrategy




    methods
        function yLimits=getYLimits(~,chartData,axesIndex)
            multiTabularIndex=chartData.IndexFactory.getIndex("MultiTabularIndex");
            tbls=multiTabularIndex.getSingleVarSubTablesForAxes(axesIndex);
            isTabularVars=cellfun(@(t)istabular(t.(1)),tbls);
            tbls(isTabularVars)=cellfun(@(t)t.(1),tbls(isTabularVars),"UniformOutput",false);
            yLimitsTbls=cellfun(@(t)matlab.graphics.chart.internal.stackedplot.getLimits(t.(1)),tbls,"UniformOutput",false);
            yLimits=matlab.graphics.chart.internal.stackedplot.getLimits([yLimitsTbls{:}]);
        end
    end
end