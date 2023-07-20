function[loadedData]=loadSlccCache(settingsChecksum,interfaceChecksum,fullChecksum)


    loadedData=[];

    try
        cacheFilePath=getSlccCachePath(settingsChecksum);
        if isfile(cacheFilePath)
            load(cacheFilePath,'-mat','data');


            okToLoad=isDiskDataValid(data,interfaceChecksum,fullChecksum);
            if okToLoad
                loadedData=data;
            else
                deleteSlccCache(settingsChecksum);
            end
        end
    catch
        loadedData=[];

        warning(['An exception occured while loading the parser cache.\n'...
        ,ex.getReport()...
        ]);
    end
end



function valid=isDiskDataValid(diskData,interfaceChecksum,fullChecksum)

    try
        interfaceChecksumUnchanged=strcmp(diskData.interfaceChecksum,interfaceChecksum);
        if~interfaceChecksumUnchanged
            valid=false;
        else
            fullChecksumUnchanged=strcmp(diskData.fullChecksum,fullChecksum);
            if fullChecksumUnchanged
                valid=true;
            else





                valid=diskData.noUndefinedFunctions&&diskData.globalIOParseNotRequired;
            end
        end
    catch

        valid=false;
    end
end