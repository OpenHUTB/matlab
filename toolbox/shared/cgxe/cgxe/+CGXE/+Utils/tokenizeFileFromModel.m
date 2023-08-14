function[fullSrcName,fileName]=tokenizeFileFromModel(givenFileName,modelName,thirdPartySourcePaths)

    projRootDir=cgxeprivate('get_cgxe_proj_root');
    modelRootDir=fileparts(get_param(modelName,'FileName'));
    if isempty(modelRootDir)
        modelRootDir=projRootDir;
    end

    searchDirectories=[thirdPartySourcePaths,...
    {projRootDir},...
    {modelRootDir},...
    CGXE.Utils.getSearchDirectoriesFromPath()];
    searchDirectories=CGXE.Utils.orderedUniquePaths(searchDirectories);

    [pathStr,fileName,ext]=fileparts(givenFileName);
    fullSrcName=givenFileName;
    if isempty(pathStr)
        processDollarAndSeps=true;
        strictTokenChk=true;
        fullSrcPath=CGXE.Utils.tokenize([],[fileName,ext],'custom source files string',searchDirectories,...
        processDollarAndSeps,strictTokenChk);

        if~isempty(fullSrcPath)
            fullSrcName=fullSrcPath{1};
        end
    end