classdef GitIntegration











    properties(GetAccess=private,SetAccess=private)
        Pref=com.mathworks.cmlink.management.preferences.HiddenAdapterFactories;
        FactoryClass='com.mathworks.cmlink.implementations.git.GitAdapterFactory';
    end

    methods(Access=public)

        function obj=turnOn(obj)
            obj.Pref.unHide(obj.FactoryClass);
        end

        function obj=turnOff(obj)
            obj.Pref.hide(obj.FactoryClass);
        end

        function on=isOn(obj)
            on=~obj.Pref.isFactoryHidden(obj.FactoryClass);
        end

        function display(obj)
            if(obj.isOn)
                status='On';
            else
                status='Off';
            end
            fprintf('Git integration is %s\n',status);
        end
    end

end
