classdef MSSCCIIntegration











    properties(GetAccess=private,SetAccess=private)
        Pref=com.mathworks.cmlink.management.preferences.HiddenAdapterFactories;
        FactoryClass='com.mathworks.cmlink.implementations.msscci.MSSCCIAdapterFactory';
    end

    methods(Access=public)

        function obj=MSSCCIIntegration()
            if(~ispc)
                msg=message('SimulinkProject:util:msscciWindowsOnly');
                error('MATLAB:sourceControl:MSSCCIWinOnly',msg.getString());
            end
        end

        function obj=turnOn(obj)
            obj.Pref.unHide(obj.FactoryClass);
        end

        function obj=turnOff(obj)
            obj.Pref.hide(obj.FactoryClass);
        end

        function on=isOn(obj)
            on=~obj.Pref.isFactoryHidden(obj.FactoryClass);
        end

        function showFolderPrefDialog(~)
            com.mathworks.cmlink.implementations.msscci.prefs.ui.Util.showPrefDialog();
        end

        function display(obj)
            if(obj.isOn)
                status='On';
            else
                status='Off';
            end
            fprintf('MS SCCI integration is %s\n',status);
        end
    end

end
