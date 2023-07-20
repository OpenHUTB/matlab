function res=isLoaded(obj,filename)




    fullFileName=cvi.ResultsExplorer.Data.getFullFileName(filename);
    res=obj.maps.fileMap.isKey(fullFileName);
end