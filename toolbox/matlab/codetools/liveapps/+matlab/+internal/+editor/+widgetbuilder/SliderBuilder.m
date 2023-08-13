classdef SliderBuilder<matlab.internal.editor.widgetbuilder.WidgetBuilder


    methods(Static)
        function slider=layout(task,parent,data)
            id=data.widget.id;
            slider=uislider(parent,'Value',data.widget.value,...
            'Limits',[data.widget.minimum,data.widget.maximum],...
            'MinorTicks',[],'MajorTicks',[data.widget.minimum,data.widget.maximum]);
            task.StatefulWidgets(id)=slider;
        end


        function updateValue(widgetInstance,value)
            widgetInstance.Value=str2double(value);
        end


        function value=fetchValuefromWidget(widgetInstance)
            value=widgetInstance.Value;
        end
    end
end