function rMap=getNameMapSingletonInstance(~)
    mlock;
    persistent nMap;
    if isempty(nMap)
        nMap=containers.Map('KeyType','char','ValueType','int32');
    end
    rMap=nMap;
end
