



classdef ImportCompFromArxml_ExcludeInternalBehavior<autosar.ui.app.base.OptionBase
    methods
        function obj=ImportCompFromArxml_ExcludeInternalBehavior(env)





            id='ImportCompFromArxml_ExcludeInternalBehavior';
            obj@autosar.ui.app.base.OptionBase(id,env);

            obj.Type='checkbox';
            obj.OptionMessage=DAStudio.message('autosarstandard:ui:uiImporterExcludeInternalBehavior');
            obj.Value='';
            obj.Answer=false;


            obj.DepInfo=struct('Option','ImportCompFromArxml_Modeling','Value',true);
            obj.Indent=1;
        end
    end
end


