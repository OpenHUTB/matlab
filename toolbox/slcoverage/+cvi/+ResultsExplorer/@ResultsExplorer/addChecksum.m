function removeIncompatibleData=addChecksum(obj,modelName,cvd)




    cc=cvd.checksum;
    cchk=[cc.u1,cc.u2,cc.u3,cc.u4];
    dbVersion=cvd.dbVersion;
    removeIncompatibleData=false;
    modelKey=obj.genModelKey(cvd,modelName);
    if isempty(obj.maps.checksumMap)
        strct=cvi.ResultsExplorer.ResultsExplorer.newChecksumInfo(modelKey,cchk,modelName,dbVersion);
        obj.maps.checksumMap=strct;
    else
        idx=find({obj.maps.checksumMap.key}==string(modelKey));
        if~isempty(idx)
            if~isequal(obj.maps.checksumMap(idx).checksum,cchk)
                obj.maps.checksumMap(idx).checksum=cchk;
                removeIncompatibleData=true;
            end
        else


            idx=find({obj.maps.checksumMap.modelName}==string(modelName));
            if~isempty(idx)
                cidx=contains({obj.maps.checksumMap(idx).key},string(modelKey));
                if~all(cidx)
                    obj.maps.checksumMap(~cidx)=[];
                    removeIncompatibleData=true;
                end
            end
            strct=cvi.ResultsExplorer.ResultsExplorer.newChecksumInfo(modelKey,cchk,modelName,dbVersion);
            obj.maps.checksumMap(end+1)=strct;
        end
    end
end

