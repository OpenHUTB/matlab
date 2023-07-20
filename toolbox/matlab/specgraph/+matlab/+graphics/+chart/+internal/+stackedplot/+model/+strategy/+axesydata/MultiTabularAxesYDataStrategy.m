classdef MultiTabularAxesYDataStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.AxesYDataStrategy




    methods
        function y=getAxesYData(~,chartData,axesIndex)
            multiTabularIndex=chartData.IndexFactory.getIndex("MultiTabularIndex");
            tbls=multiTabularIndex.getSingleVarSubTablesForAxes(axesIndex);
            y=cell(1,length(tbls));
            for i=1:length(tbls)
                data=tbls{i}.(1);
                if istabular(data)
                    y{i}=varfun(@(v)v,data,"OutputFormat","cell");
                else
                    y{i}={data};
                end
            end
            y=[y{:}];
        end
    end
end
