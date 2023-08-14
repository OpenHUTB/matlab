classdef ButtonBuilder<matlab.internal.editor.widgetbuilder.WidgetBuilder





    methods(Static)
        function button=layout(task,parent,data)
            id=data.widget.id;
            button=uibutton(parent,...
            'Text',data.widget.text);
        end
    end
end