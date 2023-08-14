

classdef ConfigCodeImporter<internal.CodeImporterUI.QuestionBase
    methods
        function obj=ConfigCodeImporter(env)
            id='ConfigCodeImporter';
            topic=message('Simulink:CodeImporterUI:Topic_SimulinkLib').getString;
            obj@internal.CodeImporterUI.QuestionBase(id,topic,env);
            obj.NextQuestionId='ConfigCodeLibrary';

            obj.getAndAddOption(env,'ConfigCodeLibrary_ProjectName');
            obj.getAndAddOption(env,'ConfigCodeLibrary_ProjectFolder');
            if~obj.Env.CodeImporter.isSLTest
                obj.getAndAddOption(env,'OptionsCreateSLBlocks_Checkbox');
                obj.getAndAddOption(env,'ConfigCodeLibrary_LibraryBrowserName');
            end
        end

        function preShow(obj)
            preShow@internal.CodeImporterUI.QuestionBase(obj);
            if obj.Env.CodeImporter.isSLTest
                obj.HintMessage=message(...
                'Simulink:CodeImporterUI:QuestionHint_ConfigCodeImporter_SLTest').getString();
            end
        end

        function onNext(obj)
            onNext@internal.CodeImporterUI.QuestionBase(obj);
            env=obj.Env;
            env.CodeImporter.qualifyProjectLibrarySettings();
            env.State.ProcessedOutputFolder=...
            env.CodeImporter.qualifiedSettings.OutputFolder;
        end
    end
end


