



classdef ImportCompFromArxml_InitializationRunnable<autosar.ui.app.base.OptionBase
    methods
        function obj=ImportCompFromArxml_InitializationRunnable(env)





            id='ImportCompFromArxml_InitializationRunnable';
            obj@autosar.ui.app.base.OptionBase(id,env);

            obj.Type='combobox';
            obj.OptionMessage=DAStudio.message('autosarstandard:ui:uiImporterInitializationRunnable');
            obj.Value={};
            obj.Answer='';


            obj.DepInfo=struct('Option','ImportCompFromArxml_Modeling','Value',true);
            obj.Indent=1;
        end
    end
end


