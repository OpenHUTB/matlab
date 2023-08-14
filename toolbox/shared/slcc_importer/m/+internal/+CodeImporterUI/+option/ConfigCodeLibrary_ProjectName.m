
classdef ConfigCodeLibrary_ProjectName<internal.CodeImporterUI.OptionBase
    methods
        function obj=ConfigCodeLibrary_ProjectName(env)
            id='ConfigCodeLibrary_ProjectName';
            obj@internal.CodeImporterUI.OptionBase(id,env);
            obj.Type='user_input';
            obj.Property='LibraryFileName';
            obj.HasHintMessage=true;
            obj.HasSummaryMessage=false;
            obj.Env.State.LibraryFileNameText=obj.Env.CodeImporter.LibraryFileName;
        end

        function onChange(obj)
            env=obj.Env;
            if isempty(strip(obj.Answer))

                obj.Answer=env.CodeImporter.LibraryFileName;
            end

            try
                env.CodeImporter.LibraryFileName=obj.Answer;
            catch e


                env.handle_error(e);
            end
            env.State.LibraryFileNameText=obj.Answer;
        end

        function applyOnNext(obj)
            env=obj.Env;
            lastAnswer=env.LastAnswer;
            values=lastAnswer.Value;
            for i=1:length(values)
                if strcmp(values(i).option,obj.Id)
                    env.CodeImporter.LibraryFileName=values(i).value;
                end
            end
        end
    end
end
