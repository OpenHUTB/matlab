
classdef ConfigCodeCompiler_Language<internal.CodeImporterUI.OptionBase
    methods
        function obj=ConfigCodeCompiler_Language(env)
            id='ConfigCodeCompiler_Language';
            obj@internal.CodeImporterUI.OptionBase(id,env);
            obj.Type='combobox';
            obj.Value={'C','C++'};
            obj.Property='Language';
            obj.HasHintMessage=true;
            obj.HasSummaryMessage=false;
        end

        function preShow(obj)
            env=obj.Env;
            obj.HideWidget=isa(env.CodeImporter,'sltest.CodeImporter')&&...
            env.CodeImporter.TestType==internal.CodeImporter.TestTypeEnum.UnitTest;
        end

        function onChange(obj)

            obj.Env.CodeImporter.CustomCode.Language=obj.Answer;
        end
    end
end
