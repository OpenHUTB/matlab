function value=getEvaluatedPropertyValue(this,qualifiedPropName)








    narginchk(2,2);

    [qualifiedPropName,propUsage]=getFQNAndUsage(this,qualifiedPropName);


    try
        propVal=this.getPrototypable.getPropVal(qualifiedPropName);
    catch

        value=[];
        return;
    end
    propType=propUsage.propertyDef.type;
    value=this.castValueToCorrectDataType(propType,propVal.expression);

end


function[updatedFQN,propUsage]=getFQNAndUsage(elem,qualifiedPropName)



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
            propUsage=[];
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
