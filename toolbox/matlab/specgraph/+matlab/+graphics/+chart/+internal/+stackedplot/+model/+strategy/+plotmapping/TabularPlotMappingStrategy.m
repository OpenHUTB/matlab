classdef TabularPlotMappingStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.PlotMappingStrategy




    methods
        function[axesMapping,plotMapping]=mapPlotObjects(~,chartData,oldState)
            if~isempty(oldState)&&isequaln(oldState.SourceTable,chartData.SourceTable)
                oldTabularIndex=oldState.IndexFactory.getIndex("TabularIndex");
            else

                oldTabularIndex=[];
            end
            tabularIndex=chartData.IndexFactory.getIndex("TabularIndex");
            [axesMapping,plotMapping]=tabularIndex.mapPlotObjects(oldTabularIndex);
        end
    end
end
