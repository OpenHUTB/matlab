classdef MultipleChoiceWidget<matlab.internal.project.preferences.widgets.PreferenceWidget




    properties(SetAccess=immutable,GetAccess=private)
        ChoiceValues(1,:)string
        ChoiceLabels(1,:)string
        Dropdown(1,1)
    end

    methods
        function obj=MultipleChoiceWidget(container,prompt,values,labels,setting)
            obj=obj@matlab.internal.project.preferences.widgets.PreferenceWidget(setting);
            rowLayout=matlab.internal.project.preferences.utils.makeFitGridLayout(container,1,2);
            rowLayout.Padding=[0,6,0,0];

            uilabel(rowLayout,"Text",prompt);

            label=labels(values==setting.ActiveValue);
            if isempty(label)
                label=labels(values==setting.FactoryValue);
            end

            obj.Dropdown=uidropdown(rowLayout);
            obj.Dropdown.Items=labels;
            obj.Dropdown.Value=label;

            obj.ChoiceValues=values;
            obj.ChoiceLabels=labels;
        end

        function commit(obj)
            obj.Value=char(...
            obj.ChoiceValues(obj.ChoiceLabels==obj.Dropdown.Value));
        end
    end
end
