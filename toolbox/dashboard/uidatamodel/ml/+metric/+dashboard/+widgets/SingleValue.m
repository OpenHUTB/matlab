classdef SingleValue<metric.dashboard.widgets.Widget&metric.dashboard.CustomProps
    properties(Constant,Hidden)
        HeightLimit=50;
        TooltipLocations={'SingleValueTitle','SingleValueValue'};


        CustomProperties={'TitleLocation','RenderMode','DrillInArrayIndex'};
        RenderModeEnum=struct('Full','full','Compact','compact');
        TitleLocationEnum=struct('Top','top','Right','right','Bottom','bottom','Left','left');
    end

    methods(Access={?metric.dashboard.WidgetFactory,?metric.dashboard.widgets.Widget})
        function obj=SingleValue(element,~)
            obj@metric.dashboard.widgets.Widget(element);
            obj@metric.dashboard.CustomProps(element.CustomProperties,mf.zero.getModel(element));
            if isempty(obj.TitleLocation)
                obj.TitleLocation=obj.TitleLocationEnum.Bottom;
            end
            if isempty(obj.RenderMode)
                obj.RenderMode=obj.RenderModeEnum.Full;
            end
        end
    end
end

