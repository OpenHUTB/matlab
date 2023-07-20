classdef LabelBuilder<matlab.internal.editor.widgetbuilder.WidgetBuilder





    methods(Static)
        function label=layout(task,parent,data)
            id=data.widget.id;
            label=uilabel(parent,'Text',data.widget.text);
        end
    end
end