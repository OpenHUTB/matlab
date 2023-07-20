
classdef ConfigCodeLibrary_IncludeFiles<internal.CodeImporterUI.OptionBase
    methods
        function obj=ConfigCodeLibrary_IncludeFiles(env)
            id='ConfigCodeLibrary_IncludeFiles';
            obj@internal.CodeImporterUI.OptionBase(id,env);
            obj.Type='files';
            obj.FileFilter={'*.h','header files (*.h)';...
            '*.hpp','header files (*.hpp)';...
            '*.*','All Files (*.*)'};
            obj.Property='InterfaceHeaders';
            obj.Value=obj.Env.CodeImporter.CustomCode.InterfaceHeaders;
            obj.HasSummaryMessage=false;
        end

        function preShow(obj)
            env=obj.Env;
            obj.HideWidget=isa(env.CodeImporter,'sltest.CodeImporter')&&...
            env.CodeImporter.TestType==internal.CodeImporter.TestTypeEnum.UnitTest;
        end

        function onChange(obj)
            obj.Env.CodeImporter.CustomCode.InterfaceHeaders=obj.extractProjDefFromUI(obj.Answer);
            obj.Answer=strjoin(obj.Env.CodeImporter.CustomCode.InterfaceHeaders,'\n').char;


        end
    end
end