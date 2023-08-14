






function varUsages=getPopulatedVarUsages(model,parametersToConsider)
    varUsages=[];
    for idx=1:length(parametersToConsider)
        if isa(parametersToConsider(idx),'Simulink.VariableUsage')&&isempty(parametersToConsider(idx).DirectUsageDetails)
            try


                varUsagesInstance=Simulink.findVars(model,'SearchReferencedModels','on','SearchMethod','cached','SourceType',parametersToConsider(idx).SourceType,'Source',parametersToConsider(idx).Source,'Name',parametersToConsider(idx).Name);
            catch
                varUsagesInstance=Simulink.findVars(model,'SearchReferencedModels','on','SourceType',parametersToConsider(idx).SourceType,'Source',parametersToConsider(idx).Source,'Name',parametersToConsider(idx).Name);
            end
        else
            varUsagesInstance=parametersToConsider(idx);
        end
        varUsages=[varUsages,varUsagesInstance];
    end
end
