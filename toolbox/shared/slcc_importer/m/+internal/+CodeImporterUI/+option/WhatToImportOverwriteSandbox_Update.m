classdef WhatToImportOverwriteSandbox_Update<internal.CodeImporterUI.OptionBase
    methods
        function obj=WhatToImportOverwriteSandbox_Update(env)
            id='WhatToImportOverwriteSandbox_Update';
            obj@internal.CodeImporterUI.OptionBase(id,env);
            obj.Type='radio';
            obj.Value=env.State.OverwriteSandbox;
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
                        env.State.OverwriteSandbox=false;
                    end
                end
            end
        end
    end
end

