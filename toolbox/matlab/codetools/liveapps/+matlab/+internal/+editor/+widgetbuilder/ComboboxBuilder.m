classdef ComboboxBuilder<matlab.internal.editor.widgetbuilder.WidgetBuilder





    methods(Static)
        function comboBox=layout(task,parent,data)
            import matlab.internal.editor.widgetbuilder.ComboboxBuilder;
            id=data.widget.id;
            comboBox=uidropdown(parent,...
            'Items',data.widget.itemLabels,...
            'ItemsData',data.widget.items);
            ComboboxBuilder.updateValue(comboBox,data.widget.value);
            task.StatefulWidgets(id)=comboBox;
        end


        function updateValue(widgetInstance,value)
            for item=widgetInstance.ItemsData
                if strcmp(item.value,value)
                    widgetInstance.Value=item;
                end
            end
        end


        function value=fetchValuefromWidget(widgetInstance)
            value=widgetInstance.Value.value;
        end
    end
end