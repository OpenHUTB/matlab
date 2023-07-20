classdef SimpleStack<metric.dashboard.widgets.Widget&metric.dashboard.CustomProps
    properties(Constant,Hidden)
        HeightLimit=40;
        TooltipLocations={'SimpleStackStack'};
        CustomProperties={'DataFormat','RenderMode','BarHeight','StateIconSize'};
        DataFormatEnum=struct('Stacked','stacked','Fraction','fraction');
        RenderModeEnum=struct('Full','full','Compact','compact');
        StateIconSizeEnum=struct('Normal','normal','Small','small');
    end

    methods(Access={?metric.dashboard.WidgetFactory,?metric.dashboard.widgets.Widget})
        function obj=SimpleStack(element,~)
            obj@metric.dashboard.widgets.Widget(element);
            obj@metric.dashboard.CustomProps(element.CustomProperties,mf.zero.getModel(element));
            if isempty(obj.DataFormat)
                obj.DataFormat=obj.DataFormatEnum.Stacked;
            end
            if isempty(obj.RenderMode)
                obj.RenderMode=obj.RenderModeEnum.Full;
            end
            if isempty(obj.BarHeight)
                obj.BarHeight='15';
            end
            if isempty(obj.StateIconSize)
                obj.StateIconSize=obj.StateIconSizeEnum.Normal;
            end
        end
    end
end

