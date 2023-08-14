function[userIncludeDirs,userSources,userLibraries,userSourcesRawTokens]=...
    getTokenizedPathsAndFiles(modelName,projRootDir,customCodeSettings,targetDir,modelRefRebuildModelRootDir,reportTokenizerError)


    if nargin<6
        reportTokenizerError=false;
    end

    isModelRefRebuild=false;
    if nargin>=5&&~isempty(modelRefRebuildModelRootDir)
        isModelRefRebuild=true;
    end

    modelRootDir=projRootDir;
    if isModelRefRebuild
        modelRootDir=modelRefRebuildModelRootDir;
    else
        if~isempty(modelName)
            modelRootDir=CGXE.Utils.getRootDirectory(modelName,pwd);
            if isempty(modelRootDir)
                modelRootDir=projRootDir;
            else

                modelLWDepDir=fullfile(modelRootDir,'slprj','_slcclw',modelName);
                if exist(modelLWDepDir,'dir')
                    modelRootDir=modelLWDepDir;
                end
            end
        end
    end

    errorStrs=[];
    if isempty(customCodeSettings.userIncludeDirs)
        userIncludeDirs={};
    else
        [userIncludeDirs,errorStr]=CGXE.Utils.tokenize(modelRootDir,customCodeSettings.userIncludeDirs,...
        DAStudio.message('Simulink:CustomCode:CustCodeIncludeDirs'),{});
        if~isempty(errorStr)
            errorStrs=[errorStrs,errorStr];
        end
    end

    userIncludeDirs=CGXE.Utils.orderedUniquePaths(userIncludeDirs);













    searchDirectories=CGXE.Utils.getSearchDirectoriesFromPath();
    searchDirectories=[{targetDir},{projRootDir},{modelRootDir},userIncludeDirs,searchDirectories];
    searchDirectories=CGXE.Utils.orderedUniquePaths(searchDirectories);
    searchDirectories(cellfun('isempty',searchDirectories))=[];

    customCodeString=customCodeSettings.customCode;

    if~isempty(customCodeString)


        customCodeIncDirs=CGXE.CustomCode.extractRelevantDirs(pwd,searchDirectories,customCodeString);
    else
        customCodeIncDirs={};
    end
    userIncludeDirs=[userIncludeDirs,customCodeIncDirs,{projRootDir},{modelRootDir}];
    userIncludeDirs=CGXE.Utils.orderedUniquePaths(userIncludeDirs);

    if isempty(customCodeSettings.userSources)
        userSources={};
        userSourcesRawTokens={};
    else
        processDollarAndSeps=true;
        strictTokenChk=true;
        [userSources,errorStr,userSourcesRawTokens]=CGXE.Utils.tokenize(modelRootDir,customCodeSettings.userSources,...
        DAStudio.message('Simulink:CustomCode:CustCodeSrcFiles'),searchDirectories,processDollarAndSeps,strictTokenChk);
        if~isempty(errorStr)
            errorStrs=[errorStrs,errorStr];
        end
    end
    userAbsPaths={};
    for j=1:length(userSources)
        [userAbsPaths{j}]=CGXE.Utils.stripPathFromName(userSources{j});%#ok<AGROW>
    end
    userIncludeDirs=[userIncludeDirs,userAbsPaths];
    userIncludeDirs=CGXE.Utils.orderedUniquePaths(userIncludeDirs);

    if isempty(customCodeSettings.userLibraries)
        userLibraries={};
    else
        processDollarAndSeps=true;
        strictTokenChk=true;
        [userLibraries,errorStr]=CGXE.Utils.tokenize(modelRootDir,customCodeSettings.userLibraries,...
        DAStudio.message('Simulink:CustomCode:CustCodeLibFiles'),searchDirectories,processDollarAndSeps,strictTokenChk);
        if~isempty(errorStr)
            errorStrs=[errorStrs,errorStr];
        end
    end

    if~isempty(errorStrs)&&reportTokenizerError
        CGXE.Utils.reportTokenizerDiagnostic(errorStrs);
    end

