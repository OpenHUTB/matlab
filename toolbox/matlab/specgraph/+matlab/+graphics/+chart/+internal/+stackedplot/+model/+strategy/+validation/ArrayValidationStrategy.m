classdef ArrayValidationStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.ValidationStrategy




    methods
        function validate(~,chartData)
            if length(chartData.XData)~=size(chartData.YData,1)
                error(message('MATLAB:stackedplot:XDataYDataMismatch'));
            end
        end
    end
end