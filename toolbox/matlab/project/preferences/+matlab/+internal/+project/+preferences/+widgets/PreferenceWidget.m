classdef(Abstract)PreferenceWidget<matlab.mixin.Heterogeneous




    properties(GetAccess=private,SetAccess=immutable)
        Setting(1,1);
    end

    properties(Dependent)
        Value;
    end

    methods
        function obj=PreferenceWidget(setting)
            obj.Setting=setting;
        end

        function obj=set.Value(obj,value)
            obj.Setting.PersonalValue=value;
        end

        function value=get.Value(obj)
            value=obj.Setting.ActiveValue;
        end
    end

    methods(Abstract)
        commit(obj);
    end
end
