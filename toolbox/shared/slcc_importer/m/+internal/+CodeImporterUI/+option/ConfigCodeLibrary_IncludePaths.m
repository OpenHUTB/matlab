
classdef ConfigCodeLibrary_IncludePaths<internal.CodeImporterUI.OptionBase
    methods
        function obj=ConfigCodeLibrary_IncludePaths(env)
            id='ConfigCodeLibrary_IncludePaths';
            obj@internal.CodeImporterUI.OptionBase(id,env);
            obj.Type='paths';
            obj.Property='IncludePaths';
            obj.HasSummaryMessage=false;
        end

        function preShow(obj)
            obj.Answer=strjoin(obj.Env.CodeImporter.CustomCode.IncludePaths,'\n').char;
        end

        function onChange(obj)
            obj.Env.CodeImporter.CustomCode.IncludePaths=obj.extractProjDefFromUI(obj.Answer);

        end
    end
end
