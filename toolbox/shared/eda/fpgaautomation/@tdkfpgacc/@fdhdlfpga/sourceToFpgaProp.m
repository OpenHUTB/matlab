function sourceToFpgaProp(hObj)



    srcData=hObj.FPGAProjectPropTableSource.GetSourceData;

    if isempty(srcData)
        PropNames='';
        PropValues='';
        PropProcesses='';
    else
        PropNames=sprintf('%s;',srcData{:,1});

        PropValues=sprintf('%s;',srcData{:,2});

        PropProcesses=sprintf('%s;',srcData{:,3});

    end

    hObj.FPGAProperties.FPGAProjectPropertyName=PropNames;
    hObj.FPGAProperties.FPGAProjectPropertyValue=PropValues;
    hObj.FPGAProperties.FPGAProjectPropertyProcess=PropProcesses;

end

