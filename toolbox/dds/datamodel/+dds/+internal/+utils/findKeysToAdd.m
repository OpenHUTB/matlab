


function keysToAdd=findKeysToAdd(map,refMap)
    validateattributes(map,{'containers.Map'},{});
    validateattributes(refMap,{'containers.Map'},{});
    refMapKeys=refMap.keys;
    numberOfKeysToAdd=0;
    for index=1:length(refMapKeys)
        theKey=refMapKeys{index};
        if~map.isKey(theKey)
            numberOfKeysToAdd=numberOfKeysToAdd+1;
        end
    end
    keysToAdd={};
    if numberOfKeysToAdd~=0
        keysToAdd=cell(1,numberOfKeysToAdd);
        idx=1;
        for index=1:length(refMapKeys)
            theKey=refMapKeys{index};
            if~map.isKey(theKey)
                keysToAdd{idx}=theKey;
                idx=idx+1;
            end
        end
    end
end