
















function activateConfigSet(this,csName)

    if nargin~=2
        DAStudio.error('RTW:cgv:InvalidNumberOfArgs');
    end
    if this.RunHasBeenCalled~=0
        DAStudio.error('RTW:cgv:RunHasBeenCalled');
    end
    if~ischar(csName)
        DAStudio.error('RTW:cgv:ParamToFcnMustBeString','activateConfigSet');
    end
    if~isempty(this.UserAddedConfigSet)
        DAStudio.error('RTW:cgv:AddConfigSetCalled');
    end




    models=find_mdlrefs(this.ModelName,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
    nameList='';
    for i=1:length(models)
        model=models{i};
        loadStatus=verifyLoaded(model);

        if isempty(getConfigSet(model,csName))
            nameList=[nameList,model,', '];%#ok<AGROW>
        end
        if strcmp(loadStatus,'notloaded')
            close_system(model,0);
        end
    end
    if~isempty(nameList)
        DAStudio.error('RTW:cgv:ConfigSetMissing',csName,nameList);
    else
        this.ConfigSetName=csName;
    end
end

