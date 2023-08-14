function createMaps(obj)



    obj.maps.uniqueIdMap=containers.Map('KeyType','char','ValueType','any');
    obj.maps.fileMap=containers.Map('KeyType','char','ValueType','any');
    obj.maps.checksumMap=cvi.ResultsExplorer.ResultsExplorer.newChecksumInfo({},{},{},{});
end
