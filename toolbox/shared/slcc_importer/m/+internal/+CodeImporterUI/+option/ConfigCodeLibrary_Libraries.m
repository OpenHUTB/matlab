
classdef ConfigCodeLibrary_Libraries<internal.CodeImporterUI.OptionBase
    methods
        function obj=ConfigCodeLibrary_Libraries(env)
            id='ConfigCodeLibrary_Libraries';
            obj@internal.CodeImporterUI.OptionBase(id,env);
            obj.Type='files';
            obj.FileFilter=initFileFilter(obj);
            obj.Property='Libraries';
            obj.HasSummaryMessage=false;
        end

        function preShow(obj)
            env=obj.Env;
            obj.HideWidget=isa(env.CodeImporter,'sltest.CodeImporter')&&...
            env.CodeImporter.TestType==internal.CodeImporter.TestTypeEnum.UnitTest;
        end

        function ff=initFileFilter(~)
            if ismac
                ff={'*.o','object files (*.o)';...
                '*.a','library files (*.a)';...
                '*.dylib','library files (*.dylib)';...
                '*.*','All Files (*.*)'};
            elseif ispc
                ff={'*.obj','object files (*.obj)';...
                '*.lib','library files (*.lib)';...
                '*.dll','library files (*.dll)';...
                '*.*','All Files (*.*)'};
            elseif isunix
                ff={'*.o','object files (*.o)';...
                '*.a','library files (*.a)';...
                '*.so','library files (*.so)';...
                '*.*','All Files (*.*)'};
            end
        end

        function onChange(obj)
            obj.Env.CodeImporter.CustomCode.Libraries=obj.extractProjDefFromUI(obj.Answer);
            obj.Answer=strjoin(obj.Env.CodeImporter.CustomCode.Libraries,'\n').char;
        end
    end
end