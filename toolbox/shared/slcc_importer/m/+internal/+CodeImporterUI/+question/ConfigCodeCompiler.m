

classdef ConfigCodeCompiler<internal.CodeImporterUI.QuestionBase
    methods
        function obj=ConfigCodeCompiler(env)
            id='ConfigCodeCompiler';
            topic=message('Simulink:CodeImporterUI:Topic_ConfigCode').getString;
            obj@internal.CodeImporterUI.QuestionBase(id,topic,env);
            obj.NextQuestionId='WhatToImportAnalyze';
            obj.getAndAddOption(env,'ConfigCodeCompiler_Language');
            obj.getAndAddOption(env,'ConfigCodeCompiler_Defines');
            obj.getAndAddOption(env,'ConfigCodeCompiler_CompilerFlags');
            obj.getAndAddOption(env,'ConfigCodeCompiler_LinkerFlags');
        end

        function onNext(obj)
            onNext@internal.CodeImporterUI.QuestionBase(obj);
            env=obj.Env;
            env.CodeImporter.qualifyProjectCompilerSettings();


            if env.IsSLTest&&obj.Env.CodeImporter.TestType==...
                internal.CodeImporter.TestTypeEnum.UnitTest
                obj.NextQuestionId='WhatToImportAnalyzeSandbox';
            else
                obj.NextQuestionId='WhatToImportAnalyze';
            end
        end
    end
end


