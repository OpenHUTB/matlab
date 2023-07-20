
classdef ConfigCodeLibrary_LibraryBrowserName<internal.CodeImporterUI.OptionBase
    methods
        function obj=ConfigCodeLibrary_LibraryBrowserName(env)
            id='ConfigCodeLibrary_LibraryBrowserName';
            obj@internal.CodeImporterUI.OptionBase(id,env);
            obj.Type='user_input';
            obj.Property='LibraryBrowserName';
            obj.HasHintMessage=true;
            obj.HasSummaryMessage=false;
            obj.Value=obj.Env.CodeImporter.Options.LibraryBrowserName;
            obj.Answer=obj.Env.CodeImporter.Options.LibraryBrowserName;
        end

        function preShow(obj)
            createSLBlock=obj.Env.State.CreateSLBlocks;
            obj.HideWidget=~createSLBlock||isa(obj.Env.CodeImporter,'sltest.CodeImporter');
        end

        function onChange(obj)
            if obj.Env.State.CreateSLBlocks
                if isempty(strip(char(obj.Answer)))
                    obj.Answer=obj.Env.State.LibraryFileNameText;
                end
                obj.Env.CodeImporter.Options.LibraryBrowserName=obj.Answer;
            else
                obj.Env.CodeImporter.Options.LibraryBrowserName="";
            end
        end
    end
end
