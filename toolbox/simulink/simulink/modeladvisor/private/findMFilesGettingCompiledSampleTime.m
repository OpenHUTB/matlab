function[mFilesOfConcern]=findMFilesGettingCompiledSampleTime(clearStoredResults)

    persistent cachedDirsToSearch;
    persistent cachedMFilesOfConcern;

    if(clearStoredResults)
        cachedDirsToSearch='';
        cachedMFilesOfConcern={};
        return
    end



    origPath=addpath(pwd);
    curPath=path;
    path(origPath);

    dirsToSearch=textscan(curPath,'%s','Delimiter',pathsep);
    dirsToSearch=dirsToSearch{:};
    toDelete=false(size(dirsToSearch));
    for idx=1:length(dirsToSearch)

        if(~isempty(strfind(dirsToSearch{idx},matlabroot))||~isempty(strfind(dirsToSearch{idx},matlabshared.supportpkg.internal.getSupportPackageRootNoCreate)))
            toDelete(idx)=true;
        else

            pathParts=textscan(dirsToSearch{idx},'%s','Delimiter',filesep);
            if(any(strcmp(pathParts{:},'slprj')))
                toDelete(idx)=true;
            end
        end
    end
    dirsToSearch(toDelete)=[];

    if isempty(cachedDirsToSearch)
        cachedDirsToSearch=dirsToSearch;
    elseif isequal(cachedDirsToSearch,dirsToSearch)
        mFilesOfConcern=cachedMFilesOfConcern;
        return
    else
        cachedDirsToSearch=dirsToSearch;
    end



    mFilesOfConcern={};

    warnState=warning('off','MATLAB:DEPFUN:DeprecatedAPI');


    for dirIdx=1:length(dirsToSearch)
        thisDir=dirsToSearch{dirIdx};

        [thisDirMFiles]=lfindFilesInDir(thisDir);
        mFilesOfConcern=[mFilesOfConcern,thisDirMFiles];%#ok<AGROW>
    end

    warning(warnState);

    cachedMFilesOfConcern=mFilesOfConcern;


    function[mFilesOfConcern]=lfindFilesInDir(thisDir)
        mFilesOfConcern={};
        fileList=what(thisDir);
        if(isempty(fileList))
            return;
        end

        theMFiles=fileList.m;
        for mFileIdx=1:length(theMFiles)
            thisMFile=theMFiles{mFileIdx};



            fid=fopen(thisMFile);
            thisMFileText=fscanf(fid,'%s');
            if(~isempty(regexp(thisMFileText,'get_param\(.*''CompiledSampleTime\''','ONCE')))
                mFilesOfConcern{end+1}=[thisDir,filesep,thisMFile];%#ok<AGROW>
            end
            fclose(fid);
        end

        theClasses=fileList.classes;
        for classDirIdx=1:length(theClasses)
            thisClassDir=[thisDir,filesep,'@',theClasses{classDirIdx}];
            prevDir=cd(thisClassDir);
            [thisDirMFiles]=lfindFilesInDir(thisClassDir);
            cd(prevDir)
            mFilesOfConcern=[mFilesOfConcern,thisDirMFiles];%#ok<AGROW>
        end

        thePackages=fileList.packages;
        for packageDirIdx=1:length(thePackages)
            thisPackageDir=[thisDir,filesep,'+',thePackages{packageDirIdx}];
            prevDir=cd(thisPackageDir);
            [thisDirMFiles]=lfindFilesInDir(thisPackageDir);
            cd(prevDir)
            mFilesOfConcern=[mFilesOfConcern,thisDirMFiles];%#ok<AGROW>
        end




