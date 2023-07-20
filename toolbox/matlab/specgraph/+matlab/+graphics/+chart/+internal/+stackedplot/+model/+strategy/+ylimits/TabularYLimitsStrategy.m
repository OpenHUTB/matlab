classdef TabularYLimitsStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.YLimitsStrategy




    methods
        function yLimits=getYLimits(~,chartData,axesIndex)
            tabularIndex=chartData.IndexFactory.getIndex("TabularIndex");
            yT=tabularIndex.getSubTableForAxes(axesIndex);
            for i=1:width(yT)
                if istabular(yT.(i))
                    yT.(i)=yT.(i).(1);
                end
            end
            yTLimits=varfun(@matlab.graphics.chart.internal.stackedplot.getLimits,yT,"OutputFormat","cell");
            yLimits=matlab.graphics.chart.internal.stackedplot.getLimits([yTLimits{:}]);
        end
    end
end