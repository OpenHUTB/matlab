classdef CreateTestHarness_Skip<internal.CodeImporterUI.OptionBase
    methods
        function obj=CreateTestHarness_Skip(env)
            id='CreateTestHarness_Skip';
            obj@internal.CodeImporterUI.OptionBase(id,env);
            obj.Type='radio';
            obj.Value=env.CodeImporter.Options.CreateTestHarness;
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
                        env.CodeImporter.Options.CreateTestHarness=false;
                    end
                end
            end
        end
    end
end

