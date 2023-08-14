
classdef ConfigCodeLibrary_SourceFiles<internal.CodeImporterUI.OptionBase
    methods
        function obj=ConfigCodeLibrary_SourceFiles(env)
            id='ConfigCodeLibrary_SourceFiles';
            obj@internal.CodeImporterUI.OptionBase(id,env);
            obj.Type='files';
            obj.FileFilter={'*.c','C files (*.c)';...
            '*.cpp','Cpp files (*.cpp)';...
            '*.*','All Files (*.*)'};
            obj.Property='SourceFiles';
            obj.HasHintMessage=true;
            obj.HasSummaryMessage=false;
        end

        function preShow(obj)
            env=obj.Env;

            if isa(env.CodeImporter,'sltest.CodeImporter')&&...
                env.CodeImporter.TestType==internal.CodeImporter.TestTypeEnum.UnitTest
                obj.FileFilter={'*.c','C files (*.c)';...
                '*.*','All Files (*.*)'};
            end
        end

        function onChange(obj)
            obj.Env.CodeImporter.CustomCode.SourceFiles=obj.extractProjDefFromUI(obj.Answer);
            obj.Answer=strjoin(obj.Env.CodeImporter.CustomCode.SourceFiles,'\n').char;
        end
    end
end