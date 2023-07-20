



classdef ImportCompFromArxml<autosar.ui.app.base.QuestionBase

    properties(Access=private,Constant)
        HelpViewIDForComponent='autosar_importer_app_file_selection';
        HelpViewIDForComposition='autosar_importer_app_composition_file_selection';
    end

    properties
        HelpViewID;
    end

    methods
        function val=get.HelpViewID(obj)
            if isa(obj.Env,'autosar.ui.app.import.ComponentImportWizard')
                val=obj.HelpViewIDForComponent;
            else
                val=obj.HelpViewIDForComposition;
            end
        end

        function obj=ImportCompFromArxml(env)





            id='ImportCompFromArxml';
            topic=DAStudio.message('autosarstandard:ui:uiImporterTopic');

            obj@autosar.ui.app.base.QuestionBase(id,topic,env);


            obj.getAndAddOption('ImportCompFromArxml_FileSelect');
            obj.NextQuestionId='CreateCompInSimulink';


            obj.QuestionMessage=DAStudio.message('autosarstandard:ui:uiImporterArxml');
            obj.HintMessage=DAStudio.message('autosarstandard:ui:uiImporterArxmlHelp');

            obj.HasBack=false;
        end

        function onChange(obj)

            env=obj.Env;

            if~isempty(env.LastAnswer)&&isa(env.LastAnswer.Value,'struct')
                obj.refreshOnFileSelection('ImportCompFromArxml_FileSelect');
            end
        end
    end
end



