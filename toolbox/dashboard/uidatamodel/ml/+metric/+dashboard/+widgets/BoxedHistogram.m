classdef BoxedHistogram<metric.dashboard.widgets.Widget&metric.dashboard.CustomProps
    properties(Constant,Hidden)
        HeightLimit=80;
        TooltipLocations={'BoxedHistogramBin','BoxedHistogramTitle'};
        CustomProperties={'RenderMode','BarHeight','MaxBinCount'};
        RenderModeEnum=struct('Full','full','Compact','compact');
    end

    methods(Access={?metric.dashboard.WidgetFactory,?metric.dashboard.widgets.Widget})
        function obj=BoxedHistogram(element,~)
            obj@metric.dashboard.widgets.Widget(element);
            obj@metric.dashboard.CustomProps(element.CustomProperties,mf.zero.getModel(element));
            if isempty(obj.RenderMode)
                obj.RenderMode=obj.RenderModeEnum.Full;
            end
            if isempty(obj.BarHeight)
                obj.BarHeight='20';
            end
        end
    end
end

