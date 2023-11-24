function simrfV2_setcachedata(cacheBlock,cacheData,cacheDataBase,blkNames)

    if nargin<4
        cacheDataBase=struct;
        blkNames={};
    end
    cacheDataOut=cacheData;
    if~isempty(blkNames)
        if isfield(cacheDataBase,[blkNames{1},'On'])&&...
            cacheDataBase.([blkNames{1},'On'])
            cacheDataOut=setfield(cacheDataBase,blkNames{:},cacheData);
        else
            cacheDataOut=cacheDataBase;
        end
    end
    set_param(cacheBlock,'UserData',cacheDataOut);

end