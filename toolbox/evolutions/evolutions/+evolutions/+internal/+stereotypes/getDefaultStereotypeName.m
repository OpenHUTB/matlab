function defaultStereotype=getDefaultStereotypeName(info)




    infoType=class(info);
    switch infoType
    case 'evolutions.model.EvolutionInfo'
        stereotype='BaseEvolutionModel';
    case 'evolutions.model.EvolutionTreeInfo'
        stereotype='BaseEvolutionTreeModel';
    otherwise
        assert(strcmp(infoType,'evolutions.model.Edge'));%#ok<STISA>
        stereotype='BaseEdgeModel';
    end
    profile=evolutions.internal.stereotypes.getDefaultProfileName;
    defaultStereotype=strcat(profile,'.',stereotype);
end
