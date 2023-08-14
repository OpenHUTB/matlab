
classdef ConfigUpdateMode_UpdateExisting<internal.CodeImporterUI.OptionBase
    methods
        function obj=ConfigUpdateMode_UpdateExisting(env)
            id='UpdateExisting';
            obj@internal.CodeImporterUI.OptionBase(id,env);
            obj.Type='radio';
            obj.Value=~env.State.OverwriteLibraryModel;
            obj.Answer=~env.State.OverwriteLibraryModel;
            obj.HasMessage=true;
            obj.HasHintMessage=false;
            obj.HasSummaryMessage=false;
        end

        function onChange(obj)

            env=obj.Env;
            lastAnswer=env.LastAnswer;
            values=lastAnswer.Value;
            for i=1:length(values)
                if strcmp(values(i).option,obj.Id)
                    if(values(i).value)
                        env.State.OverwriteLibraryModel=false;
                    end
                end
            end
        end
    end
end