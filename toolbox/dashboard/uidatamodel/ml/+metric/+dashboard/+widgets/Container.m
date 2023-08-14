classdef Container<metric.dashboard.widgets.WidgetBase&metric.dashboard.widgets.WidgetContainer

    properties(Access=protected)
Configuration
    end

    methods(Access={?metric.dashboard.WidgetFactory,?metric.dashboard.widgets.Container})
        function obj=Container(element,config)
            obj=obj@metric.dashboard.widgets.WidgetBase(element);
            obj.Configuration=config;
        end
    end

    methods(Access=protected)
        function mf0Obj=getMF0Object(this)
            mf0Obj=this.MF0Widget;
        end
    end
end
