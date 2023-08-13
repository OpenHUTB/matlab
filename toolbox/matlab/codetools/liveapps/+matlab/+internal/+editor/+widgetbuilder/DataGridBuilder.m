classdef DataGridBuilder<matlab.internal.editor.widgetbuilder.WidgetBuilder


    methods(Static)


        function canHandleOwnChildren=processEachWidget(task,grid,data,type)
            import matlab.internal.editor.widgetbuilder.WidgetClassHandler;

            className=WidgetClassHandler.getClassName(type);
            widget=matlab.internal.editor.widgetbuilder.(className).layout(task,grid,data);

            widget.Layout.Row=data.widget.parentOptions.row;
            widget.Layout.Column=data.widget.parentOptions.column;
            canHandleOwnChildren=false;
        end

        function g=layout(task,parent,data)

            if isempty(parent)
                grid=matlab.task.LiveTaskUtilitiesBridge.getLayoutManager(task);
            else

                grid=uigridlayout(parent);
            end

            grid.RowHeight=repmat({'fit'},1,data.widget.rows);
            grid.ColumnWidth=repmat({'fit'},1,data.widget.columns);

            import matlab.internal.editor.widgetbuilder.DataGridBuilder;
            import matlab.internal.editor.widgetbuilder.Utilities;
            Utilities.parse(data.widget.children,@(childData,type)DataGridBuilder.processEachWidget(task,grid,childData,type));
        end
    end
end