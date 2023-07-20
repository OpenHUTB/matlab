
function data=addCvData(obj,cvd,fileName)




    if~obj.maps.uniqueIdMap.isKey(cvd.uniqueId)
        data=cvi.ResultsExplorer.Data(fileName,cvd);
        addDataToMaps(obj,data);
    else

        data=obj.maps.uniqueIdMap(cvd.uniqueId);
        data.setFileName(fileName);
        obj.maps.fileMap(data.fullFileName)=data;
    end

end