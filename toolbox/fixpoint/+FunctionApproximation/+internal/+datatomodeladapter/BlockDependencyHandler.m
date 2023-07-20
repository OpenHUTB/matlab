classdef BlockDependencyHandler





    methods
        function allVariables=getAllVariables(~,blockSID)
            allVariables=FunctionApproximation.internal.datatomodeladapter.VariableUsageProxy.empty;
            try



                variableUsages=Simulink.findVars(Simulink.ID.getFullName(blockSID),'SearchMethod','cached');
            catch
                variableUsages=Simulink.findVars(Simulink.ID.getFullName(blockSID));
            end
            nUsages=numel(variableUsages);
            for iUsage=1:nUsages
                allVariables(iUsage)=FunctionApproximation.internal.datatomodeladapter.VariableUsageProxy(variableUsages(iUsage));
            end
        end

        function transferModelWorkspaceVariables(~,variableNames,newModelWorkspace,oldModelWorkspace)



            for iVar=1:numel(variableNames)
                variableName=variableNames{iVar};
                newModelWorkspace.assignin(variableName,slprivate('modelWorkspaceGetVariableHelper',oldModelWorkspace,variableName));
            end
        end
    end
end
