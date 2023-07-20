function defaultProps=getPropertiesUsingDefaultValuesInStereotypeHierarchy(elem,stereotypeName)








    defaultProps={};

    propNames=elem.getPropertyNames();
    for propName=propNames
        if contains(propName,stereotypeName)
            if(elem.isPropValDefault(propName{1}))
                defaultProps=[defaultProps,propName{1}];%#ok<AGROW>
            end
        end
    end

end

