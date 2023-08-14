function baseName=cacheFileBaseName(moduleId,itemId)
    persistent lastModuleId lastItemId lastBaseName;
    if isempty(lastBaseName)||~strcmp(moduleId,lastModuleId)||~strcmp(lastItemId,itemId)
        myTempDir=fullfile(tempdir,'RMI','DOORS');
        if exist(myTempDir,'dir')~=7
            mkdir(myTempDir);
        end
        objNumStr=rmidoors.getNumericStr(itemId,moduleId);
        lastBaseName=fullfile(myTempDir,[moduleId,'_',objNumStr]);
        lastModuleId=moduleId;
        lastItemId=itemId;
    end
    baseName=lastBaseName;
end
