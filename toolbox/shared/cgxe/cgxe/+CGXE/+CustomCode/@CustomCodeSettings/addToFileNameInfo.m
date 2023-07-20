function[fileNameInfo,errorStrs]=addToFileNameInfo(obj,fileNameInfo,model,extraIncludeDirs,codingForSimulation)

    if nargin<5
        codingForSimulation=true;
    end

    if nargin<4
        extraIncludeDirs={};
    end


    currentDirPath=pwd;

    errorStrs={};

    if codingForSimulation
        fileNameInfo.customCompilerFlags=obj.customCompilerFlags;
        fileNameInfo.customLinkerFlags=obj.customLinkerFlags;
    end
    fileNameInfo.customUserDefines=obj.customUserDefines;

    rootDirectory=CGXE.Utils.getRootDirectory(model,currentDirPath);

    if~obj.hasSettings()
        fileNameInfo.userIncludeDirs=[...
        {fileNameInfo.targetDirName},{currentDirPath},{rootDirectory}];
        fileNameInfo.userIncludeDirs=CGXE.Utils.orderedUniquePaths(fileNameInfo.userIncludeDirs);
    else



        processDollarAndSeps=true;
        strictTokenChkForIncludes=false;
        if(~codingForSimulation&&strcmp(get_param(model,'GenCodeOnly'),'on'))


            strictTokenChkForIncludes=-1;
        end
        [fileNameInfo.userIncludeDirs,errorStr]=...
        CGXE.Utils.tokenize(rootDirectory...
        ,obj.userIncludeDirs...
        ,'custom include directory paths string'...
        ,{},...
        processDollarAndSeps,...
        strictTokenChkForIncludes);
        if~isempty(errorStr)
            errorStrs=[errorStrs,errorStr];
        end

        if isempty(extraIncludeDirs)
            fileNameInfo.userIncludeDirs=[...
            {fileNameInfo.targetDirName},{currentDirPath},{rootDirectory},...
            fileNameInfo.userIncludeDirs];
        else
            fileNameInfo.userIncludeDirs=[...
            {fileNameInfo.targetDirName},{currentDirPath},{rootDirectory},...
            extraIncludeDirs,fileNameInfo.userIncludeDirs];
        end

        fileNameInfo.userIncludeDirs=CGXE.Utils.orderedUniquePaths(fileNameInfo.userIncludeDirs);


        searchDirectories=regexp(matlabpath,pathsep,'split');
        if ispc
            filterIndices=strncmpi(searchDirectories,matlabroot,length(matlabroot));
        else
            filterIndices=strncmp(searchDirectories,matlabroot,length(matlabroot));
        end
        searchDirectories(filterIndices)=[];
        searchDirectories=[fileNameInfo.userIncludeDirs,searchDirectories];
        searchDirectories=CGXE.Utils.orderedUniquePaths(searchDirectories);
        customCodeString=obj.customCode;
        if~isempty(customCodeString)


            customCodeIncDirs=CGXE.CustomCode.extractRelevantDirs(rootDirectory,searchDirectories,customCodeString);
        else
            customCodeIncDirs={};
        end
        fileNameInfo.userIncludeDirs=[fileNameInfo.userIncludeDirs,customCodeIncDirs];
        fileNameInfo.userIncludeDirs=CGXE.Utils.orderedUniquePaths(fileNameInfo.userIncludeDirs);
    end


    strictTokenChkForSrcLib=true;
    if(~codingForSimulation&&strcmp(get_param(model,'GenCodeOnly'),'on'))
        strictTokenChkForSrcLib=-1;
    end

    userSourceStr=obj.userSources;

    if isempty(userSourceStr)
        fileNameInfo.userSources={};
    else
        processDollarAndSeps=true;


        [fileNameInfo.userSources,errorStr]=...
        CGXE.Utils.tokenize(...
rootDirectory...
        ,userSourceStr...
        ,'custom source files string'...
        ,searchDirectories,...
        processDollarAndSeps,...
        strictTokenChkForSrcLib);
        if~isempty(errorStr)
            errorStrs=[errorStrs,errorStr];
        end
    end

    userLibrariesStr=obj.userLibraries;

    if(isempty(userLibrariesStr))
        fileNameInfo.userLibraries={};
    else
        processDollarAndSeps=true;
        [fileNameInfo.userLibraries,errorStr]=...
        CGXE.Utils.tokenize(...
rootDirectory...
        ,userLibrariesStr...
        ,'custom libraries string'...
        ,searchDirectories...
        ,processDollarAndSeps...
        ,strictTokenChkForSrcLib);
        if~isempty(errorStr)
            errorStrs=[errorStrs,errorStr];
        end
    end

    fileNameInfo.userMakefiles={};
    fileNameInfo.userAbsSources={};
    fileNameInfo.userAbsPaths={};
    for i=1:length(fileNameInfo.userSources)
        [fileNameInfo.userAbsPaths{i}...
        ,fileNameInfo.userAbsSources{i}...
        ,fileNameInfo.userSources{i}]=...
        CGXE.Utils.stripPathFromName(fileNameInfo.userSources{i});
    end


    fileNameInfo.userAbsPaths=CGXE.Utils.orderedUniquePaths(fileNameInfo.userAbsPaths);
    fileNameInfo.userIncludeDirs=[fileNameInfo.userIncludeDirs...
    ,fileNameInfo.userAbsPaths];
    fileNameInfo.userIncludeDirs=CGXE.Utils.orderedUniquePaths(fileNameInfo.userIncludeDirs);


