classdef SpinnerBuilder<matlab.internal.editor.widgetbuilder.WidgetBuilder




    methods(Static)
        function spinner=layout(task,parent,data)
            id=data.widget.id;
            spinner=uispinner(parent,'Value',data.widget.value,...
            'Step',data.widget.step,...
            'Limits',[data.widget.minimum,data.widget.maximum]);
            task.StatefulWidgets(id)=spinner;
        end


        function updateValue(widgetInstance,value)
            widgetInstance.Value=str2double(value);
        end


        function value=fetchValuefromWidget(widgetInstance)
            value=widgetInstance.Value;
        end
    end
end