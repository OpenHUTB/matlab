


function keysToDelete=findKeysToDelete(map,refMap)
    validateattributes(map,{'containers.Map'},{});
    validateattributes(refMap,{'containers.Map'},{});
    mapKeys=map.keys;
    numberOfKeysToDelete=0;
    for index=1:length(mapKeys)
        theKey=mapKeys{index};
        if~refMap.isKey(theKey)
            numberOfKeysToDelete=numberOfKeysToDelete+1;
        end
    end
    keysToDelete={};
    if numberOfKeysToDelete~=0
        keysToDelete=cell(1,numberOfKeysToDelete);
        idx=1;
        for index=1:length(mapKeys)
            theKey=mapKeys{index};
            if~refMap.isKey(theKey)
                keysToDelete{idx}=theKey;
                idx=idx+1;
            end
        end
    end
end