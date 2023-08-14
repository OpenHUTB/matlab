



classdef ImportCompFromArxml_CompName<autosar.ui.app.base.OptionBase
    methods
        function obj=ImportCompFromArxml_CompName(env)





            id='ImportCompFromArxml_CompName';
            obj@autosar.ui.app.base.OptionBase(id,env);

            obj.Type='combobox';
            if isa(env,'autosar.ui.app.import.CompositionImportWizard')
                obj.OptionMessage=DAStudio.message('autosarstandard:ui:uiImporterCompositionName');
            else
                obj.OptionMessage=DAStudio.message('autosarstandard:ui:uiImporterComponentName');
            end
            obj.Value={};
            obj.Answer='';
        end
    end
end


