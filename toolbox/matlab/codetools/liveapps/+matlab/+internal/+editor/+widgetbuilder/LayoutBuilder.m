classdef LayoutBuilder<matlab.internal.editor.widgetbuilder.WidgetBuilder


    methods(Static)


        function canHandleOwnChildren=processWidget(task,parent,data,type)
            import matlab.internal.editor.widgetbuilder.WidgetClassHandler;

            className=WidgetClassHandler.getClassName(type);
            matlab.internal.editor.widgetbuilder.(className).layout(task,parent,data);

            canHandleOwnChildren=true;
        end

        function layout(task,parent,data)
            import matlab.internal.editor.widgetbuilder.Utilities;
            import matlab.internal.editor.widgetbuilder.LayoutBuilder;

            Utilities.parse(data,@(data,type)LayoutBuilder.processWidget(task,parent,data,type));
        end
    end
end
