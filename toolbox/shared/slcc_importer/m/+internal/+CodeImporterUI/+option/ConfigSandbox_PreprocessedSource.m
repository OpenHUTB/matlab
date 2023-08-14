classdef ConfigSandbox_PreprocessedSource<internal.CodeImporterUI.OptionBase
    methods
        function obj=ConfigSandbox_PreprocessedSource(env)
            id='ConfigSandbox_PreprocessedSource';
            obj@internal.CodeImporterUI.OptionBase(id,env);
            obj.Type='radio';
            obj.HasMessage=true;
            obj.HasHintMessage=true;
            obj.HasSummaryMessage=false;
        end

        function onChange(obj)

            env=obj.Env;
            lastAnswer=env.LastAnswer;
            values=lastAnswer.Value;
            for i=1:length(values)
                if strcmp(values(i).option,obj.Id)
                    if(values(i).value)
                        env.CodeImporter.SandboxSettings.Mode=...
                        internal.CodeImporter.SandboxTypeEnum.GeneratePreprocessedSource;
                    end
                end
            end
        end
    end
end

