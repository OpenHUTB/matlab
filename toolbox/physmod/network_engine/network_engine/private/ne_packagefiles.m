function files=ne_packagefiles(pkg,fileExt,includePrivate)








    [pkgPath,pkgName]=fileparts(pkg);
    if isempty(pkgPath)
        pkgPath=pwd;
    end

    if nargin==2
        includePrivate=false;
    end

    cwd=cd(fullfile(pkgPath,pkgName));

    c=onCleanup(@()cd(cwd));
    files=lGetSupportedFiles('.',fileExt,includePrivate);

end

function supportedFiles=lGetSupportedFiles(d,fileExt,includePrivate)

    cwd=cd(d);
    dirInfo=dir('+*');
    isDir=[dirInfo(:).isdir];
    packageDirs=dirInfo(isDir);


    allFilesInDir={};
    fileBaseNames={};
    for idx=1:numel(fileExt)
        filesInDir=dir(['*',fileExt{idx}]);
        if~isempty(filesInDir)
            f=strrep({filesInDir(:).name},fileExt{idx},'');
            fileBaseNames={fileBaseNames{:},f{:}};
            allFilesInDir={allFilesInDir{:},filesInDir(:).name};
        end

        if includePrivate
            privateDirContents=dir(['private',filesep,'*',fileExt{idx}]);
            if~isempty(privateDirContents)
                privateFiles=strcat(['private',filesep],{privateDirContents(:).name});
                allFilesInDir={allFilesInDir{:},privateFiles{:}};
            end
        end


    end

    if~isempty(allFilesInDir)

        supportedFiles=strcat([pwd,filesep],allFilesInDir);
    else
        supportedFiles={};
    end

    packageNamesInCurrentDir=regexprep({packageDirs(:).name},'^+.','');
    [packageAndFileNameClash,packageClashIdx]=intersect(packageNamesInCurrentDir,fileBaseNames);

    if~isempty(packageAndFileNameClash)
        clashingPackageNames=packageNamesInCurrentDir(packageClashIdx);
        str=clashingPackageNames{1};
        for idx=2:numel(clashingPackageNames)
            str=sprintf('%s\n%s',str,clashingPackageNames{idx});
        end
        pm_error('physmod:network_engine:ne_packagefiles:PackageFileNameClash',pm_fullpath(d),str);
    end

    for idx=1:numel(packageDirs)
        supportedFilesInPkg=lGetSupportedFiles(packageDirs(idx).name,fileExt,includePrivate);
        supportedFiles={supportedFiles{:},supportedFilesInPkg{:}};
    end

    cd(cwd);
end
