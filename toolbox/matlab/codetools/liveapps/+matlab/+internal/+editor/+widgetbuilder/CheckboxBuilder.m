classdef CheckboxBuilder<matlab.internal.editor.widgetbuilder.WidgetBuilder


    methods(Static)
        function checkbox=layout(task,parent,data)
            id=data.widget.id;
            checkbox=uicheckbox(parent,...
            'Value',data.widget.value,...
            'Text',data.widget.text);
            task.StatefulWidgets(id)=checkbox;
        end


        function updateValue(widgetInstance,value)
            if islogical(value)
                widgetInstance.Value=value;
            else
                widgetInstance.Value=strcmp(value,'true');
            end
        end


        function value=fetchValuefromWidget(widgetInstance)
            value=widgetInstance.Value;
        end
    end

end