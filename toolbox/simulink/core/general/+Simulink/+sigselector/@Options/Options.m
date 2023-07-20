classdef Options


































    properties
        ViewType='DDG';
        RootName=DAStudio.message('Simulink:sigselector:OptionsCurrentlySelectedSignals');
        TreeMultipleSelection=true;
        InteractiveSelection=false;
        BusSupport='all';
        MdlrefSupport='none';
        SfSupport=false;
        Model='';
        HideBusRoot=false;
        FilterVisible=true;
        AutoSelect=false;
    end

    methods

        function obj=Options(varargin)
            for ct=1:length(varargin)/2
                try
                    obj.(varargin{2*ct-1})=varargin{2*ct};
                catch Me
                    if strcmp(Me.identifier,'MATLAB:noPublicFieldForClass')

                        DAStudio.error('Simulink:sigselector:OptionsInvalidParam',varargin{2*ct-1});
                    else
                        rethrow(Me);
                    end
                end
            end
        end

        function obj=set.InteractiveSelection(obj,val)
            if islogical(val)
                obj.InteractiveSelection=val;
            else
                DAStudio.error('Simulink:sigselector:OptionsInvalidInteractiveSelection');
            end
        end
        function obj=set.FilterVisible(obj,val)
            if islogical(val)
                obj.FilterVisible=val;
            else
                DAStudio.error('Simulink:sigselector:OptionsInvalidFilterVisible');
            end
        end
        function obj=set.AutoSelect(obj,val)
            if islogical(val)
                obj.AutoSelect=val;
            else
                DAStudio.error('Simulink:sigselector:OptionsInvalidAutoSelect');
            end
        end
        function obj=set.TreeMultipleSelection(obj,val)
            if islogical(val)
                obj.TreeMultipleSelection=val;
            else
                DAStudio.error('Simulink:sigselector:OptionsInvalidTreeMultipleSelection');
            end
        end
        function obj=set.HideBusRoot(obj,val)
            if islogical(val)
                obj.HideBusRoot=val;
            else
                DAStudio.error('Simulink:sigselector:OptionsInvalidHideBusRoot');
            end
        end
        function obj=set.BusSupport(obj,val)
            if any(strcmp(val,{'none','wholeonly','elementonly','all'}))
                obj.BusSupport=val;
            else
                DAStudio.error('Simulink:sigselector:OptionsInvalidBusSupport');
            end
        end
        function obj=set.MdlrefSupport(obj,val)
            if any(strcmp(val,{'none','normalonly','all'}))
                obj.MdlrefSupport=val;
            else
                DAStudio.error('Simulink:sigselector:OptionsInvalidMdlrefSupport');
            end
        end
        function obj=set.SfSupport(obj,val)
            if islogical(val)
                obj.SfSupport=val;
            else
                DAStudio.error('Simulink:sigselector:OptionsInvalidSfSupport');
            end
        end
        function obj=set.RootName(obj,val)
            if ischar(val)
                obj.RootName=val;
            else
                DAStudio.error('Simulink:sigselector:OptionsInvalidRootName');
            end
        end
        function obj=set.ViewType(obj,val)
            if any(strcmp(val,{'Java','DDG'}))
                obj.ViewType=val;
            else
                DAStudio.error('Simulink:sigselector:OptionsInvalidViewType');
            end
        end
        function obj=set.Model(obj,val)
            if ischar(val)
                obj.Model=val;
            else
                DAStudio.error('Simulink:sigselector:OptionsInvalidModel');
            end
        end
    end

end


