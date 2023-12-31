classdef MultiTablePropertyGroupsStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.PropertyGroupsStrategy




    methods
        function groups=getPropertyGroups(~,~)
            groups=matlab.mixin.util.PropertyGroup({...
            'SourceTable',...
            'DisplayVariables',...
            'XVariable',...
            'CombineMatchingNames',...
            'LegendLabels',...
            'Color',...
            'LineStyle',...
            'LineWidth',...
            'Marker',...
'MarkerSize'...
            });
        end
    end
end
