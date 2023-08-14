



classdef ImportCompFromArxml_ComponentModels<autosar.ui.app.base.OptionBase
    methods
        function obj=ImportCompFromArxml_ComponentModels(env)





            id='ImportCompFromArxml_ComponentModels';
            obj@autosar.ui.app.base.OptionBase(id,env);

            obj.Type='file';
            obj.OptionMessage=DAStudio.message('autosarstandard:ui:uiImporterComponentModels');
            obj.Value={};
            obj.Value.file='';
            obj.Value.folder='';
            obj.Value.browse='modelSelect';
            obj.Answer=true;


            obj.DepInfo=struct('Option','ImportCompFromArxml_Modeling','Value',true);
            obj.Indent=1;
        end
    end
end


