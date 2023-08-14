



classdef ImportCompFromArxml_PredefinedVariant<autosar.ui.app.base.OptionBase
    methods
        function obj=ImportCompFromArxml_PredefinedVariant(env)





            id='ImportCompFromArxml_PredefinedVariant';
            obj@autosar.ui.app.base.OptionBase(id,env);

            obj.Type='combobox';
            obj.OptionMessage=DAStudio.message('autosarstandard:ui:uiImporterPredefinedVariant');
            obj.Value={};
            obj.Answer='';


            obj.DepInfo=struct('Option','ImportCompFromArxml_Modeling','Value',true);
            obj.Indent=1;
        end
    end
end


