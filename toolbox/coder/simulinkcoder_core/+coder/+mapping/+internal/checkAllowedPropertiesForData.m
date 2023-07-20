


function checkAllowedPropertiesForData(property,allowedProps,allowedProfileProps,...
    mappingType,modelIdentifierType,modelIdentifier)
    if~any(ismember(property,allowedProps))&&~any(ismember(property,allowedProfileProps))
        allAllowedProps=strjoin(allowedProps,', ');
        if~isempty(allowedProfileProps)
            allAllowedProps=strcat(allAllowedProps,', ',...
            strjoin(allowedProfileProps,', '));
        end
        DAStudio.error('coderdictionary:api:invalidPropertyName',property,...
        mappingType,modelIdentifierType,modelIdentifier,allAllowedProps);
    end
end
