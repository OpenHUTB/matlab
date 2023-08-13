classdef RefactorLiveTask<matlab.task.LiveTask


    properties(Access=private)

SerializedLayout
CodeTemplate
DefaultValues
    end

    properties

State
Summary


StatefulWidgets
    end

    methods(Access=public)

        function createLayout(task,refactoredTaskMeta)
            import matlab.internal.editor.widgetbuilder.LayoutBuilder;

            task.SerializedLayout=jsondecode(refactoredTaskMeta.layoutData);
            task.CodeTemplate=refactoredTaskMeta.codeTemplate;
            task.DefaultValues=refactoredTaskMeta.defaultValues;

            LayoutBuilder.layout(task,struct.empty,task.SerializedLayout);
        end


        function reset(task)
            import matlab.internal.editor.widgetbuilder.WidgetClassHandler;

            if~isempty(task.StatefulWidgets)
                allPossibleKeys=keys(task.StatefulWidgets);

                for k=1:length(allPossibleKeys)
                    currentKey=allPossibleKeys{k};
                    widget=task.StatefulWidgets(currentKey);
                    defaultValue=task.DefaultValues.(currentKey);
                    widgetType=widget.Type;
                    className=WidgetClassHandler.getClassName(widgetType);
                    matlab.internal.editor.widgetbuilder.(className).updateValue(widget,defaultValue);
                end
            end
        end




        function[code,outputs]=generateCode(task)
            import matlab.internal.editor.widgetbuilder.WidgetClassHandler;
            allPossibleKeys=keys(task.StatefulWidgets);
            code=task.CodeTemplate;
            outputs={};


            for k=1:length(allPossibleKeys)
                currentKey=allPossibleKeys{k};
                widget=task.StatefulWidgets(currentKey);
                widgetType=widget.Type;
                className=WidgetClassHandler.getClassName(widgetType);
                valueToUpdateInCode=matlab.internal.editor.widgetbuilder.(className).fetchValuefromWidget(widget);


                code=replace(code,append("${",currentKey,".value}"),string(valueToUpdateInCode));
            end
        end
    end

    methods(Access=protected)
        function setup(task)

            task.State=containers.Map;


            task.StatefulWidgets=containers.Map;
        end
    end

    methods

        function state=get.State(task)
            state=struct();


            if~isempty(task.StatefulWidgets)
                allKeys=keys(task.StatefulWidgets);
                for i=1:length(task.StatefulWidgets)
                    field=allKeys{i};
                    state.(field).Value=task.StatefulWidgets(field).Value;
                end
            end
        end


        function set.State(task,state)
            if~isempty(task.StatefulWidgets)
                allKeys=keys(task.StatefulWidgets);

                for i=1:length(task.StatefulWidgets)
                    field=allKeys{i};
                    element=task.StatefulWidgets(field);
                    element.Value=state.(field).Value;
                end
            end
        end
    end
end