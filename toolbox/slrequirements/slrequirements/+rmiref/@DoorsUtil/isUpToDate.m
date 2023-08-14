function yesno=isUpToDate(cacheFilePath,moduleId,item)




    if exist(cacheFilePath,'file')~=2
        yesno=false;
        return;
    end


    dateStr=rmidoors.getObjAttribute(moduleId,item,'Last Modified On');
    doorsDate=datenum(dateStr)+1;
    fInfo=dir(cacheFilePath);
    cacheDate=fInfo.datenum;
    if doorsDate>cacheDate
        yesno=false;
    else
        yesno=isSameView(moduleId,[cacheFilePath,'.cols']);
    end
end

function yesno=isSameView(moduleId,colsFile)
    cols=rmidoors.getModuleAttribute(moduleId,'columns');
    colsString=strcat(cols{:});
    if exist(colsFile,'file')~=2
        yesno=false;
    else

        fid=fopen(colsFile,'r');
        colsInFile=fread(fid,'*char')';
        fclose(fid);
        yesno=strcmp(colsString,colsInFile);
    end
end
