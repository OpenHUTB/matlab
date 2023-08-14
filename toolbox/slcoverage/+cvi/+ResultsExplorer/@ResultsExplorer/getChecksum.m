function checksum=getChecksum(obj)




    checksum=[];
    if isempty(obj.maps.checksumMap)
        return;
    end
    modes=SlCov.CovMode.getSupportedValues();
    for ii=1:numel(modes)
        modelKey=SlCov.CoverageAPI.mangleModelcovName(obj.topModelName,modes(ii));
        idx=find({obj.maps.checksumMap.key}==string(modelKey));
        if~isempty(idx)
            checksum=obj.maps.checksumMap(idx).checksum;
            return
        end
    end
end