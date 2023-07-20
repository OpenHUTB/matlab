
classdef WhatToImportFunction_EntryFunctions<internal.CodeImporterUI.OptionBase

    methods
        function obj=WhatToImportFunction_EntryFunctions(env)
            id='WhatToImportFunction_EntryFunctions';
            obj@internal.CodeImporterUI.OptionBase(id,env);
            obj.Type='checkbox';

            obj.Property='FilterEntryFunctions';
            obj.Value=env.State.FilterEntryFunctions;
            obj.HasSummaryMessage=false;
            obj.HasHintMessage=false;
        end

        function onChange(obj)
            env=obj.Env;
            lastAnswer=env.LastAnswer;
            values=lastAnswer.Value;
            for i=1:length(values)
                if strcmp(values(i).option,obj.Id)
                    env.State.FilterEntryFunctions=logical(values(i).value);
                end
            end
        end
    end
end
