



classdef ImportCompFromArxml_Modeling<autosar.ui.app.base.OptionBase
    methods
        function obj=ImportCompFromArxml_Modeling(env)





            id='ImportCompFromArxml_Modeling';
            obj@autosar.ui.app.base.OptionBase(id,env);

            obj.Type='checkbox';
            obj.OptionMessage=DAStudio.message('autosarstandard:ui:uiImporterModelingOptions');
            obj.Answer=false;
            obj.Value='arxml';
        end

        function msg=getHintMessage(obj)
            if obj.Answer
                msg=DAStudio.message('autosarstandard:ui:uiImporterModelingOptionsHelp');
            else
                msg=obj.HintMessage;
            end
        end
    end
end


