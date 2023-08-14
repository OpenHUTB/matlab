classdef CreateTestHarness_Auto<internal.CodeImporterUI.OptionBase
    methods
        function obj=CreateTestHarness_Auto(env)
            id='CreateTestHarness_Auto';
            obj@internal.CodeImporterUI.OptionBase(id,env);
            obj.Type='radio';
            obj.Value=env.CodeImporter.Options.CreateTestHarness;
            obj.HasMessage=true;
            obj.HasHintMessage=false;
            obj.HasSummaryMessage=false;
            obj.Answer=true;
            obj.Value=true;
        end

        function onChange(obj)

            env=obj.Env;
            lastAnswer=env.LastAnswer;
            values=lastAnswer.Value;
            for i=1:length(values)
                if strcmp(values(i).option,obj.Id)
                    if(values(i).value)
                        env.CodeImporter.Options.CreateTestHarness=true;
                    end
                end
            end
        end
    end

end

