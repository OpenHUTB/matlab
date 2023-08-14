

classdef ConfigCodeLibrary<internal.CodeImporterUI.QuestionBase
    methods
        function obj=ConfigCodeLibrary(env)
            id='ConfigCodeLibrary';
            topic=message('Simulink:CodeImporterUI:Topic_ConfigCode').getString;
            obj@internal.CodeImporterUI.QuestionBase(id,topic,env);
            obj.NextQuestionId='WhatToImportAnalyze';
            obj.getAndAddOption(env,'ConfigCodeCompiler_Language');
            obj.getAndAddOption(env,'ConfigCodeLibrary_IncludeFiles');
            obj.getAndAddOption(env,'ConfigCodeLibrary_SourceFiles');
            obj.getAndAddOption(env,'ConfigCodeLibrary_IncludePaths');
            obj.getAndAddOption(env,'ConfigCodeLibrary_Libraries');
            obj.getAndAddOption(env,'ConfigCodeCompiler_Defines');


        end

        function preShow(obj)
            preShow@internal.CodeImporterUI.QuestionBase(obj);
            if obj.Env.CodeImporter.isSLUnitTest
                obj.HintMessage=message(...
                'Simulink:CodeImporterUI:QuestionHint_ConfigCodeLibrary').getString();
            else
                obj.HintMessage=[...
                message('Simulink:CodeImporterUI:QuestionHint_ConfigCodeLibrary_InferHeaders',obj.Env.Gui.getWandImage).getString...
                ,message('Simulink:CodeImporterUI:QuestionHint_ConfigCodeLibrary').getString...
                ];
            end
        end

        function onNext(obj)
            env=obj.Env;
            try
                env.CodeImporter.qualifyCustomCodeSettings();
                env.CodeImporter.qualifyProjectCompilerSettings();
            catch ME
                if isequal(ME.identifier,...
                    'Simulink:CodeImporter:EmptyInterfaceHeader')
                    err=MException(message('Simulink:CodeImporter:EmptyInterfaceHeaderUI'));
                    throw(err);
                else

                    rethrow(ME);
                end
            end
            onNext@internal.CodeImporterUI.QuestionBase(obj);


            if env.IsSLTest&&obj.Env.CodeImporter.TestType==...
                internal.CodeImporter.TestTypeEnum.UnitTest
                obj.NextQuestionId='ConfigSandbox';
            else
                obj.NextQuestionId='WhatToImportAnalyze';
            end
        end
    end
end


