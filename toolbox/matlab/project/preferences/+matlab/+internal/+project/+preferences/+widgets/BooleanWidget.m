classdef BooleanWidget<matlab.internal.project.preferences.widgets.PreferenceWidget




    properties(GetAccess=private,SetAccess=immutable)
Checkbox
    end

    methods
        function obj=BooleanWidget(container,label,setting)
            obj=obj@matlab.internal.project.preferences.widgets.PreferenceWidget(setting);
            obj.Checkbox=uicheckbox(container);
            obj.Checkbox.Text=label;
            obj.Checkbox.Value=setting.ActiveValue;
        end

        function commit(obj)
            obj.Value=obj.Checkbox.Value;
        end
    end
end
