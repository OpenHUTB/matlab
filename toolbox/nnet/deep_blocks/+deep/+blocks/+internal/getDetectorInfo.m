function detectorInfo=getDetectorInfo(block,detectorToLoad)




    persistent cache;
    if isempty(cache)
        cache=containers.Map('KeyType','char','ValueType','any');
    end

    [~,timeStamp,canCache]=coder.internal.getFileInfo(detectorToLoad);

    createNewDetectorInfo=true;
    if cache.isKey(block)
        detectorInfo=cache(block);
        createNewDetectorInfo=...
        ~strcmp(detectorInfo.DetectorToLoad,detectorToLoad)||...
        detectorInfo.TimeStamp~=timeStamp;
    end

    if createNewDetectorInfo
        detectorInfo=deep.blocks.internal.DetectorInfo(detectorToLoad,timeStamp);
        if canCache
            cache(block)=detectorInfo;
        end
    end

end
