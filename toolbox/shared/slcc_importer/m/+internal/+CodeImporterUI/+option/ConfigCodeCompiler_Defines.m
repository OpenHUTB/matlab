
classdef ConfigCodeCompiler_Defines<internal.CodeImporterUI.OptionBase
    methods
        function obj=ConfigCodeCompiler_Defines(env)
            id='ConfigCodeCompiler_Defines';
            obj@internal.CodeImporterUI.OptionBase(id,env);
            obj.Type='path';
            obj.Property='Defines';
            obj.HasSummaryMessage=false;
        end
        function onChange(obj)

            obj.Env.CodeImporter.CustomCode.Defines=obj.extractProjDefFromUI(obj.Answer);
        end
    end
end