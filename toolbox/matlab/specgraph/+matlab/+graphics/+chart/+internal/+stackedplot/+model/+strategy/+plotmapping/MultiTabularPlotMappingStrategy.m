classdef MultiTabularPlotMappingStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.PlotMappingStrategy




    methods
        function[axesMapping,plotMapping]=mapPlotObjects(~,chartData,oldState)
            if~isempty(oldState)&&isequaln(oldState.SourceTable,chartData.SourceTable)
                oldMultiTabularIndex=oldState.IndexFactory.getIndex("MultiTabularIndex");
            else

                oldMultiTabularIndex=[];
            end
            multiTabularIndex=chartData.IndexFactory.getIndex("MultiTabularIndex");
            [axesMapping,plotMapping]=multiTabularIndex.mapPlotObjects(oldMultiTabularIndex);
        end
    end
end
