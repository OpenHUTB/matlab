classdef StackedBar<metric.dashboard.widgets.Widget&metric.dashboard.CustomProps
    properties(Constant,Hidden)
        HeightLimit=150;
        TooltipLocations={'StackedBarTitle','StackedBarBar'};
        CustomProperties={'YMin','YMax','UseStrictMinMax'};
    end

    methods(Access={?metric.dashboard.WidgetFactory,?metric.dashboard.widgets.Widget})
        function obj=StackedBar(element,~)
            obj@metric.dashboard.widgets.Widget(element);
            obj@metric.dashboard.CustomProps(element.CustomProperties,mf.zero.getModel(element));
            if isempty(obj.YMin)
                obj.YMin='NaN';
            end
            if isempty(obj.YMax)
                obj.YMax='NaN';
            end
            if isempty(obj.UseStrictMinMax)
                obj.UseStrictMinMax='on';
            end
        end
    end

    methods
        function verify(this)
            verify@metric.dashboard.widgets.Widget(this);
            if isempty(this.Groups)
                if numel(this.Labels)~=numel(this.MetricIDs)
                    error(message('dashboard:uidatamodel:WrongLabelCount',...
                    this.Type,this.Title));
                end
            else
                if numel(this.Labels)~=numel(this.Groups)
                    error(message('dashboard:uidatamodel:WrongLabelCount',...
                    this.Type,this.Title));
                end
            end
        end
    end
end

