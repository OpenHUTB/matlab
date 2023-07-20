

function containersMap=convertMF0MapToContainersMap(MF0Map)
    validateattributes(MF0Map,{'mf.zero.Map'},{'scalar'});
    keys=MF0Map.keys;
    if iscell(keys)
        containersMap=containers.Map('KeyType','char','ValueType','any');
        for index=1:length(keys)
            theKey=keys{index};
            containersMap(theKey)=MF0Map{theKey};
        end
    else
        validateattributes(keys,{'numeric'},{});
        containersMap=containers.Map('KeyType',class(keys),'ValueType','any');
        for index=1:length(keys)
            theKey=keys(index);
            containersMap(theKey)=MF0Map{theKey};
        end
    end
end