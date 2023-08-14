classdef ConfigSandbox_AggregatedHeader<internal.CodeImporterUI.OptionBase
    methods
        function obj=ConfigSandbox_AggregatedHeader(env)
            id='ConfigSandbox_AggregatedHeader';
            obj@internal.CodeImporterUI.OptionBase(id,env);
            obj.Type='radio';
            obj.HasMessage=true;
            obj.HasHintMessage=true;
            obj.HasSummaryMessage=false;
            obj.Answer=true;
            obj.Value=true;
        end

        function preShow(obj)
            if length(obj.Env.CodeImporter.CustomCode.SourceFiles)==1
                obj.Answer=obj.Env.CodeImporter.SandboxSettings.Mode==...
                internal.CodeImporter.SandboxTypeEnum.GenerateAggregatedHeader;
                obj.Value=obj.Env.CodeImporter.SandboxSettings.Mode==...
                internal.CodeImporter.SandboxTypeEnum.GenerateAggregatedHeader;
                obj.Disabled=false;
            else
                obj.Answer=false;
                obj.Value=false;
                obj.Disabled=true;



                if obj.Env.CodeImporter.SandboxSettings.Mode==...
                    internal.CodeImporter.SandboxTypeEnum.GenerateAggregatedHeader
                    obj.Env.CodeImporter.SandboxSettings.Mode=...
                    internal.CodeImporter.SandboxTypeEnum.UseOriginalCode;
                end
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
                        internal.CodeImporter.SandboxTypeEnum.GenerateAggregatedHeader;
                    end
                end
            end
        end
    end
end