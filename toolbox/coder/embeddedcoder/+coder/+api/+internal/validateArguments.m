function validateArguments(modelH,mapping)



    if isempty(mapping)
        DAStudio.error('coderdictionary:api:noDefaultMapping');
    end
    if~strcmp(get_param(modelH,'IsERTTarget'),'on')
        DAStudio.error('coderdictionary:api:supportedForErt');
    end
end


