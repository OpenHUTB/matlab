function isInScope=findInScopeOf(selectedSystemSID,knownSIDStrings)






    isInScope=false;



    refModels=find_mdlrefs(Simulink.ID.getFullName(selectedSystemSID),'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);

    if numel(refModels)>1
        referencedModels=refModels(1:(end-1));
    else
        referencedModels={};
    end

    foundValidEntry=false;

    for validIDIdx=1:2:numel(knownSIDStrings)
        knownSID=knownSIDStrings(validIDIdx).Content;
        if Simulink.ID.isValid(knownSID)
            foundValidEntry=true;
            break;
        end
    end



    if foundValidEntry

        if Simulink.ID.isDescendantOf(selectedSystemSID,knownSID)||...
            strcmp(selectedSystemSID,Simulink.ID.getSimulinkParent(knownSID))
            isInScope=true;
            return;
        end

        if~isempty(referencedModels)
            knownIDModel=Simulink.ID.getModel(knownSID);
            if ismember(knownIDModel,referencedModels)
                isInScope=true;
                return;
            end
        end
    end