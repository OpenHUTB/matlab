function[parentDir,packageName]=ne_packagenamefromdirectorypath(fileDir)







    firstPlus=regexp(fileDir,'+','once');
    if isempty(firstPlus)
        parentDir=fileDir;
        packageName='';
        return;
    end



    parentDir=fileDir(1:firstPlus-1);
    packageName=fileDir(firstPlus+1:end);
    fileSep=regexp(packageName,filesep,'once');
    if~isempty(fileSep)
        packageName=packageName(1:fileSep-1);
    end

end

