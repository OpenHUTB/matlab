function emcBuildClean(bldDirectory,buildInfo,hasBuildFolder)








    cleanGenericFiles(bldDirectory);
    cleanPreviousBuild(bldDirectory,buildInfo,hasBuildFolder);
end


function cleanGenericFiles(bldDirectory)

    filesToClean=[
    {'rtw_proj.tmw','build.ninja','codedescriptor.dmr','codedescriptor.dmr-journal'},...
    getGeneratedDeepLearningBinaryFiles(bldDirectory),...
    getGeneratedDatFiles(bldDirectory)
    ];
    cellfun(@(file)removeSpecifiedFile(bldDirectory,file),filesToClean);

    specialDir={'sil','pil','target','coderassumptions','interface'};
    cellfun(@(dirname)removeSpecifiedDir(bldDirectory,dirname),specialDir);
end


function removeSpecifiedFile(aParentDir,aFile)
    if isfile(fullfile(aParentDir,aFile))
        emcRemoveFile(aParentDir,aFile);
    end
end


function removeSpecifiedDir(aParentDir,aDir)
    fullPath=fullfile(aParentDir,aDir);
    if isfolder(fullPath)
        emcDeleteDir(fullPath);
    end
end


function cleanPreviousBuild(bldDirectory,aBuildInfo,hasBuildFolder)

    if isempty(aBuildInfo)
        return
    end
    sources=getGeneratedSourceFiles(aBuildInfo);
    emcRemoveFile(bldDirectory,sources);

    if hasBuildFolder
        if ispc
            arch='win64';
        elseif ismac
            arch='maci64';
        else
            arch='glnxa64';
        end
        objectFolder=fullfile(bldDirectory,'build',arch);
        emcDeleteDir(objectFolder);
    else
        if ispc
            objext='.obj';
        else
            objext='.o';
        end
        oldExt={'.c$','.cpp$','.cu$'};
        newExt={objext,objext,objext};

        emcRemoveFile(bldDirectory,regexprep(sources,oldExt,newExt));
    end

    headers=getGeneratedIncludeFiles(aBuildInfo);
    emcRemoveFile(bldDirectory,headers);

    cfFile=getClangFormatfile(aBuildInfo);
    if~isempty(cfFile)
        emcRemoveFile(bldDirectory,cfFile);
    end
end


function file=getClangFormatfile(buildInfo)
    concatenatePaths=false;
    replaceMatlabroot=true;
    file='';
    files=buildInfo.getNonBuildFiles(concatenatePaths,replaceMatlabroot);
    for i=1:numel(files)
        [~,f,~]=fileparts(files(i));
        if f=="_clang-format"
            file=files{i};
            return;
        end
    end
end


function sources=getGeneratedSourceFiles(buildInfo)
    concatenatePaths=false;
    replaceMatlabroot=true;
    includeGroups={'','Interface'};
    excludeGroups={'CustomCode'};
    sources=buildInfo.getSourceFiles(concatenatePaths,replaceMatlabroot,includeGroups,excludeGroups);
end


function sources=getGeneratedIncludeFiles(buildInfo)
    concatenatePaths=false;
    replaceMatlabroot=true;
    includeGroups={'','Interface'};
    excludeGroups={'CustomCode'};
    sources=buildInfo.getIncludeFiles(concatenatePaths,replaceMatlabroot,includeGroups,excludeGroups);
end


function files=getGeneratedDatFiles(bldDirectory)
    dirlist=dir(fullfile(bldDirectory,'*.dat'));
    files={dirlist(:).name};
end


function binaryFiles=getGeneratedDeepLearningBinaryFiles(bldDirectory)
    parameterDirlist=dir(fullfile(bldDirectory,'cnn_*'));
    networkMetaDataDirlist=dir(fullfile(bldDirectory,'networkParamsInfo_*.bin'));
    binaryFiles={parameterDirlist(:).name,networkMetaDataDirlist(:).name};
end
