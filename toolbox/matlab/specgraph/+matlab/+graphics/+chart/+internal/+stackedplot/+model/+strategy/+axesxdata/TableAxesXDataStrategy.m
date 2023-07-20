classdef TableAxesXDataStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.AxesXDataStrategy




    methods
        function x=getAxesXData(~,chartData,~)
            xVariable=chartData.XVariable;
            if isempty(xVariable)
                x={1:height(chartData.SourceTable)};
            else
                if matlab.internal.datatypes.isScalarText(xVariable)
                    x={chartData.SourceTable.(xVariable)};
                else
                    tbls=chartData.SourceTable;
                    x=cell(1,length(tbls));
                    for i=1:length(tbls)
                        x{i}=tbls{i}.(xVariable{i});
                    end
                end
            end
        end
    end
end