function updatedFQN=getPropertyFQN(elem,qualifiedPropName)







    parts=strsplit(qualifiedPropName,'.');

    if length(parts)==1
        error('systemcomposer:API:MustIncludeProfileAndStereotypInFQN',message('SystemArchitecture:API:MustIncludeProfileAndStereotypInFQN',qualifiedPropName).getString);
    elseif length(parts)==2
        warning('systemcomposer:API:MustIncludeProfileInFQN',message('SystemArchitecture:API:MustIncludeProfileInFQN',qualifiedPropName).getString);
        stereotypes=elem.getStereotypes;
        idx=contains(stereotypes,['.',parts{1}]);
        if any(idx)
            stereotypeFQN=stereotypes{idx};
        else
            updatedFQN=qualifiedPropName;
            return;
        end
        propName=parts{2};
    else
        stereotypeFQN=[parts{1},'.',parts{2}];
        propName=parts{3};
    end

    propUsage=elem.getPropertyUsage(stereotypeFQN,propName);
    if~isempty(propUsage)
        updatedFQN=[propUsage.propertySet.getName,'.',propUsage.getName];
    else
        updatedFQN=[stereotypeFQN,'.',propName];
    end


end

