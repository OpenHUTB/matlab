classdef EditFieldBuilder<matlab.internal.editor.widgetbuilder.WidgetBuilder


    methods(Static)
        function editField=layout(task,parent,data)
            id=data.widget.id;

            switch data.widget.valueType
            case 'Double'
                editField=uieditfield(parent,'numeric');
                if(isnumeric(data.widget.value))
                    editField.Value=data.widget.value;
                end
                task.StatefulWidgets(id)=editField;
            case{'String','Char'}
                editField=uieditfield(parent,'Placeholder','Enter text');

                editField.Value=data.widget.value;

                task.StatefulWidgets(id)=editField;
            case 'MATLAB code'
                editField=uieditfield(parent,...
                'Value',data.widget.value,...
                'Placeholder','Enter MATLAB code');
                task.StatefulWidgets(id)=editField;
            end
        end

        function updateValue(widgetInstance,value)
            switch(widgetInstance.Type)
            case 'uinumericeditfield'
                widgetInstance.Value=str2double(value);
            otherwise
                widgetInstance.Value=value;
            end
        end


        function value=fetchValuefromWidget(widgetInstance)
            value=widgetInstance.Value;
        end
    end
end