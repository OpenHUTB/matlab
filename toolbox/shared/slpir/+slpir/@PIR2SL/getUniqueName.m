function uniqueName=getUniqueName(slBlockName)




    nMap=slpir.PIR2SL.getNameMapSingletonInstance;
    if~nMap.isKey(slBlockName)
        nMap(slBlockName)=int32(1);%#ok<NASGU>
        uniqueName=slBlockName;
        return;
    end

    counter=nMap(slBlockName);
    uniqueName=[slBlockName,int2str(counter)];

    while nMap.isKey(uniqueName)
        counter=counter+int32(1);
        uniqueName=[slBlockName,int2str(counter)];
    end

    nMap(uniqueName)=int32(1);
    nMap(slBlockName)=counter+int32(1);%#ok<NASGU>
end
