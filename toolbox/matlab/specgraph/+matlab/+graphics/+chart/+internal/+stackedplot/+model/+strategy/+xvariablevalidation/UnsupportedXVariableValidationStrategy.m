classdef UnsupportedXVariableValidationStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.XVariableValidationStrategy





    methods
        function xVariable=validateXVariable(~,~,~,~)%#ok<STOUT> 
            error(message('MATLAB:stackedplot:XVariableTablesOnly'));
        end
    end
end
