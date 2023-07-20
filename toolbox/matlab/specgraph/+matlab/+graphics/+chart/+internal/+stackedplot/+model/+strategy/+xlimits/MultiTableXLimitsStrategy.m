classdef MultiTableXLimitsStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.XLimitsStrategy




    methods
        function xLimits=getXLimits(~,chartData)
            tbls=chartData.SourceTable;
            if isempty(chartData.XVariable)
                xvars={};
            else
                xvars=cellstr(chartData.XVariable);
            end
            if isempty(xvars)
                data=arrayfun(@(i)1:height(tbls{i}),1:length(tbls),"UniformOutput",false);
            else
                if isscalar(xvars)
                    data=arrayfun(@(i)tbls{i}.(xvars{1}),1:length(tbls),"UniformOutput",false);
                else
                    data=arrayfun(@(i)tbls{i}.(xvars{i}),1:length(tbls),"UniformOutput",false);
                end
            end
            data=cellfun(@(x)x(:),data,"UniformOutput",false);
            xLimits=matlab.graphics.chart.internal.stackedplot.getLimits(vertcat(data{:}));
        end
    end
end