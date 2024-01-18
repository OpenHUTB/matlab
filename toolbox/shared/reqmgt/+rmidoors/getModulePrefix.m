function prefix=getModulePrefix(moduleId)

    persistent localMap;
    if isempty(localMap)||isempty(moduleId)
        localMap=containers.Map('KeyType','char','ValueType','char');
        if isempty(moduleId)
            prefix=[];
            return;
        end
    end

    moduleId=strtok(moduleId);

    if isKey(localMap,moduleId)
        prefix=localMap(moduleId);
    else
        prefix=rmidoors.getModuleAttribute(moduleId,'Prefix');
        localMap(moduleId)=prefix;
    end
end
