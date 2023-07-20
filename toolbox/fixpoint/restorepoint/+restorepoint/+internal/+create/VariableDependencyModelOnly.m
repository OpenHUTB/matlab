classdef VariableDependencyModelOnly<restorepoint.internal.create.VariableDependencyStrategy






    methods
        function run(~,restoreData)
            [~,model]=fileparts(restoreData.OriginalModel);
            variableUsage=...
            Simulink.findVars(model,'SourceType','base workspace','SearchReferencedModels','on');
            for varIdx=1:length(variableUsage)
                restoreData.OriginalWorkspaceVariables{varIdx}=variableUsage(varIdx).Name;
            end
        end
    end

end
