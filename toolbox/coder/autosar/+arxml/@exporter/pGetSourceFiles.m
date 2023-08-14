function files=pGetSourceFiles(buildInfo,~)

























    ws=warning;
    wsRestoreFcn=onCleanup(@()warning(ws));
    warning('off','RTW:buildInfo:unableToFindMinimalIncludes');

    buildInfo.updateFilePathsAndExtensions();
    buildInfo.findIncludeFiles();








    [srcFilePaths,srcFileNames]=buildInfo.getFullFileList('source');
    [incFilePaths,incFileNames]=buildInfo.getFullFileList('include');


    delete(wsRestoreFcn);






    sysName=buildInfo.ModelName;
    [stubHFileNames,stubCFileNames]=i_get_stub_filenames(sysName,buildInfo);
    legacyFileNames=buildInfo.getFiles('source',false,false,{'Legacy'});
    srcFilePaths=i_exclude_files(srcFileNames,srcFilePaths,[stubCFileNames,legacyFileNames]);
    incFilePaths=i_exclude_files(incFileNames,incFilePaths,stubHFileNames);

    files=[srcFilePaths,incFilePaths];






    matlabRoot=buildInfo.Settings.Matlabroot;
    if~strcmp(matlabRoot(end),filesep)
        matlabRoot=[matlabRoot,filesep];
    end
    matlabRootLen=length(matlabRoot);
    matlabRootIdx=cellfun(@(n)strncmp(n,matlabRoot,matlabRootLen),files);


    startDirs=buildInfo.getSourcePaths(true,{'StartDir'});
    startDir=startDirs{1};
    if~strcmp(startDir(end),filesep)
        startDir=[startDir,filesep];
    end
    startDirLen=length(startDir);
    startDirIdx=cellfun(@(n)strncmp(n,startDir,startDirLen),files);



    matlabRootIdx=matlabRootIdx&~startDirIdx;

    [~,matlab]=fileparts(matlabRoot(1:end-1));
    files(matlabRootIdx)=cellfun(@(n)[matlab,n(matlabRootLen:end)],files(matlabRootIdx),'UniformOutput',false);
    files(startDirIdx)=cellfun(@(n)n(startDirLen+1:end),files(startDirIdx),'UniformOutput',false);
end

function paths=i_exclude_files(names,paths,exc)

    [~,namesToKeepIdx]=setdiff(names,exc);
    paths=paths(namesToKeepIdx);

end

function[stubHFileNames,stubCFileNames]=i_get_stub_filenames(sysName,buildInfo)



    SFcnGroupCFileNames=buildInfo.getFiles('source',true,true,{''});
    SFcnGroupHFileNames=buildInfo.getFiles('include',true,true,{''});
    buildDir=RTW.getBuildDir(sysName);
    stubFolder=fullfile(buildDir.RelativeBuildDir,autosar.mm.mm2rte.RTEGenerator.getRTEFilesSubFolder);
    stubFolder=regexprep(stubFolder,'[\\/]',filesep);
    stubHFileNames=SFcnGroupHFileNames(contains(SFcnGroupHFileNames,stubFolder));

    for i=1:length(stubHFileNames)
        [~,f,e]=fileparts(stubHFileNames{i});
        stubHFileNames{i}=[f,e];
    end
    stubHFileNames=[stubHFileNames,autosar.mm.mm2rte.RTEGenerator.StaticRTEHeaderFiles];
    stubCFileNames=SFcnGroupCFileNames(contains(SFcnGroupCFileNames,stubFolder));

    for i=1:length(stubCFileNames)
        [~,f,e]=fileparts(stubCFileNames{i});
        stubCFileNames{i}=[f,e];
    end
end





