classdef OptionsGlobalIO_Checkbox<internal.CodeImporterUI.OptionBase




    methods
        function obj=OptionsGlobalIO_Checkbox(env)
            id='OptionsGlobalIO_Checkbox';
            obj@internal.CodeImporterUI.OptionBase(id,env);
            obj.Type='checkbox';

            obj.Property='SupportGlobalVariable';
            obj.Value=env.CodeImporter.CustomCode.GlobalVariableInterface;
            obj.HasSummaryMessage=false;
            obj.HasHintMessage=false;
        end

        function preShow(obj)



            env=obj.Env;
            obj.Value=env.CodeImporter.CustomCode.GlobalVariableInterface;
        end

        function onChange(obj)
            env=obj.Env;
            lastAnswer=env.LastAnswer;
            values=lastAnswer.Value;
            for i=1:length(values)
                if strcmp(values(i).option,obj.Id)
                    if(values(i).value)
                        env.CodeImporter.CustomCode.GlobalVariableInterface=true;
                    else
                        env.CodeImporter.CustomCode.GlobalVariableInterface=false;
                    end
                    env.CodeImporter.qualifiedSettings.CustomCode.GlobalVariableInterface=...
                    env.CodeImporter.CustomCode.GlobalVariableInterface;

                    env.CodeImporter.ParseInfo.invalidateFunctions();
                end
            end
        end
    end
end
