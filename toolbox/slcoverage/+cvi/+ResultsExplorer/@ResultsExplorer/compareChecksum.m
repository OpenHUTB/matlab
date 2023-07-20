function res=compareChecksum(obj,cvd,modelName)




    cc=cvd.checksum;
    cca=[cc.u1,cc.u2,cc.u3,cc.u4];
    dbVersion=cvd.dbVersion;
    res=false;


    if isempty(obj.maps.checksumMap)
        res=true;
        return
    end

    modelKey=obj.genModelKey(cvd,modelName);
    idx=find({obj.maps.checksumMap.key}==string(modelKey));
    if~isempty(idx)
        cm=obj.maps.checksumMap(idx);
        res=isequal(cm.checksum,cca)&&...
        strcmpi(cm.dbVersion,dbVersion);
    end

    if~res
        for idx=1:numel(obj.maps.checksumMap)
            cm=obj.maps.checksumMap(idx);
            if isequal(cm.checksum,cca)&&...
                strcmpi(cm.dbVersion,cvd.dbVersion)
                res=true;
                return;
            end
        end
    end

end
