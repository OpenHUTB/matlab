function[pkgFunction,pkgRelPath]=ne_filetopackagefunction(filePath)









    if iscell(filePath)
        pkgFunction=cell(1,numel(filePath));
        pkgRelPath=cell(1,numel(filePath));
        for idx=1:numel(filePath);
            [pFun,pRelPath]=lFilePathToPackageFunction(filePath{idx});
            pkgFunction{idx}=pFun;
            pkgRelPath{idx}=pRelPath;

        end
    else
        [pkgFunction,pkgRelPath]=lFilePathToPackageFunction(filePath);
    end

end


function[pkgFunction,pkgRelPath]=lFilePathToPackageFunction(filePath)


    if isempty(filePath)
        pkgFunction='';
        pkgRelPath='';
        return;
    end


    filePath=pm_fullpath(filePath);


    [pkgParentDir,filePathRelativeToPkg]=strtok(filePath,'+');%#ok<ASGLU>


    if isempty(filePathRelativeToPkg)


        [~,fName,ext]=fileparts(filePath);
        pkgFunction=fName;
        pkgRelPath=[fName,ext];
        return;
    end



    pkgRelPath=filePathRelativeToPkg;

    if isempty(filePathRelativeToPkg)
        pkgFunction='';
        return;
    end


    [packagePathToFile,fileName]=fileparts(filePathRelativeToPkg);



    pkgFunction=[strrep(strrep(packagePathToFile,filesep,'.'),'+',''),'.',fileName];

end

