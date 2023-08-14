classdef ArrayPlotMappingStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.PlotMappingStrategy




    methods
        function[axesMapping,plotMapping]=mapPlotObjects(~,chartData,oldState)
            numAxes=width(chartData.YData(:,:));
            if~isempty(oldState)&&isequaln(oldState.XData,chartData.XData)&&isequaln(oldState.YData,chartData.YData)
                axesMapping=1:numAxes;
                plotMapping=ones(1,numAxes);
            else
                axesMapping=zeros(1,numAxes);
                plotMapping=axesMapping;
            end
        end
    end
end
