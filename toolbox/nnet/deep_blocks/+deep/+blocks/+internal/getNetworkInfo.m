function networkInfo=getNetworkInfo(block,networkToLoad)




    persistent cache;
    if isempty(cache)
        cache=containers.Map('KeyType','char','ValueType','any');
    end

    [~,timeStamp,canCache]=coder.internal.getFileInfo(networkToLoad);

    createNewNetworkInfo=true;
    if cache.isKey(block)
        networkInfo=cache(block);
        createNewNetworkInfo=...
        ~strcmp(networkInfo.NetworkToLoad,networkToLoad)||...
        networkInfo.TimeStamp~=timeStamp;
    end

    if createNewNetworkInfo
        networkInfo=deep.blocks.internal.NetworkInfo(networkToLoad,timeStamp);
        if canCache
            cache(block)=networkInfo;
        end
    end

end
