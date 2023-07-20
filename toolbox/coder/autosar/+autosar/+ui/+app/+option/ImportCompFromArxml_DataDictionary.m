



classdef ImportCompFromArxml_DataDictionary<autosar.ui.app.base.OptionBase
    methods
        function obj=ImportCompFromArxml_DataDictionary(env)





            id='ImportCompFromArxml_DataDictionary';
            obj@autosar.ui.app.base.OptionBase(id,env);

            obj.Type='user_input';
            obj.OptionMessage=DAStudio.message('autosarstandard:ui:uiImporterDataDictionary');

            obj.Type='file';
            slddPath=env.getCompositionDataDictionary();
            [folder,file,ext]=fileparts(slddPath);
            obj.Value.folder=folder;
            if~isempty(file)
                obj.Value.file=[file,ext];
            else
                obj.Value.file='';
            end
            obj.Value.browse='dataDictionarySelect';
            obj.Answer=true;


            obj.DepInfo=struct('Option','ImportCompFromArxml_Modeling','Value',true);
            obj.Indent=1;
        end
    end
end


