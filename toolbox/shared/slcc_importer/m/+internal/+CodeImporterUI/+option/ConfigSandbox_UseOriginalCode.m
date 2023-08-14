classdef ConfigSandbox_UseOriginalCode<internal.CodeImporterUI.OptionBase
    methods
        function obj=ConfigSandbox_UseOriginalCode(env)
            id='ConfigSandbox_UseOriginalCode';
            obj@internal.CodeImporterUI.OptionBase(id,env);
            obj.Type='radio';
            obj.HasMessage=true;
            obj.HasHintMessage=true;
            obj.HasSummaryMessage=false;
        end

        function preShow(obj)
            if obj.Env.CodeImporter.SandboxSettings.Mode==...
                internal.CodeImporter.SandboxTypeEnum.UseOriginalCode
                obj.Answer=true;
                obj.Value=true;
                obj.Disabled=false;
            end
        end

        function onChange(obj)

            env=obj.Env;
            lastAnswer=env.LastAnswer;
            values=lastAnswer.Value;
            for i=1:length(values)
                if strcmp(values(i).option,obj.Id)
                    if(values(i).value)
                        env.CodeImporter.SandboxSettings.Mode=...
                        internal.CodeImporter.SandboxTypeEnum.UseOriginalCode;
                    end
                end
            end
        end
    end
end

