function result=rtw_resolve_custom_code...
    (modelName,lCodeFormat,lStartDirToRestore,lBuildDirectory,...
    userIncludePaths,userSrcFiles,userLibFiles)





    modelPath=getModelRootPath(modelName);

    try
        if(~strcmp(lCodeFormat,'Accelerator_S-Function'))


            sfCustomCodeInfo=sf_rtw('get_custom_code_info',modelName);
            if(~isempty(sfCustomCodeInfo))
                userIncludePaths=[userIncludePaths,10,sfCustomCodeInfo.userIncludeDirs];
                userSrcFiles=[userSrcFiles,10,sfCustomCodeInfo.userSources];
                userLibFiles=[userLibFiles,10,sfCustomCodeInfo.userLibraries];
            end
        end
    catch me %#ok<NASGU>
    end



    doStrictChkForIncludesResolve=false;
    if(strcmp(get_param(modelName,'GenCodeOnly'),'on'))
        doStrictChkForIncludesResolve=-1;
    end
    parsedIncludePaths=i_resolveFiles(modelPath,userIncludePaths,...
    'custom include directory paths string',{},doStrictChkForIncludesResolve);

    parsedIncludePaths=RTW.reduceRelativePath(parsedIncludePaths);

    if i_folderContainsHeaderFiles(modelPath)
        parsedIncludePaths=[parsedIncludePaths,{modelPath}];
    end
    parsedIncludePaths=[parsedIncludePaths,{lStartDirToRestore},{lBuildDirectory}];
    parsedIncludePaths=unique(parsedIncludePaths,'stable');




    mlPath=regexp(matlabpath,pathsep,'split');
    if(ispc)
        filter=strncmpi(mlPath,matlabroot,length(matlabroot));
    else
        filter=strncmp(mlPath,matlabroot,length(matlabroot));
    end
    mlPath(filter)=[];
    searchPath=[parsedIncludePaths,{modelPath},mlPath];
    searchPath=unique(searchPath,'stable');



    customCodeIncludeDirs=do_extract_relevant_dirs(modelPath,mlPath,userSrcFiles);
    parsedIncludePaths=[parsedIncludePaths,customCodeIncludeDirs];
    parsedIncludePaths=unique(parsedIncludePaths,'stable');

    isResolveFilesChkStrict=true;
    if(strcmp(get_param(modelName,'GenCodeOnly'),'on'))
        isResolveFilesChkStrict=-1;
    end


    parsedSrcFiles=i_resolveFiles(modelPath,userSrcFiles,...
    'custom source files string',searchPath,isResolveFilesChkStrict);

    parsedSrcFiles=RTW.reduceRelativePath(parsedSrcFiles);


    parsedLibFiles=i_resolveFiles(modelPath,userLibFiles,...
    'custom libraries string',searchPath,isResolveFilesChkStrict);


    parsedSrcPaths=cell(size(parsedSrcFiles));
    parsedSrcFileNames=cell(size(parsedSrcFiles));
    for i=1:length(parsedSrcFiles)
        [parsedSrcPaths{i},parsedSrcFileNames{i}]=parseFullFileName(parsedSrcFiles{i});
    end


    parsedSrcPaths=unique(parsedSrcPaths,'stable');
    parsedIncludePaths=[parsedIncludePaths,parsedSrcPaths];
    parsedIncludePaths=unique(parsedIncludePaths,'stable');


    result.parsedIncludePaths=parsedIncludePaths;
    result.parsedLibFiles=parsedLibFiles;
    result.parsedSrcFiles=parsedSrcFiles;
    result.parsedSrcPaths=parsedSrcPaths;
    result.parsedSrcFileNames=parsedSrcFileNames;



    function result=getModelRootPath(modelName)

        fileName=which(modelName);

        if strcmp(fileName,'new Simulink model')




            genModel=coder.internal.SubsystemBuild.getGenModelHdl;
            if ishandle(genModel)
                blockHandle=coder.internal.SubsystemBuild.getOrigBlockHdl;
                if ishandle(blockHandle)
                    fileName=bdroot(getfullname(blockHandle));
                    fileName=which(fileName);
                end
            end
        end





        if~contains(fileName,'new Test Harness')
            pathStr=fileparts(fileName);
        else
            pathStr='';
        end

        result=pathStr;



        function[pathStr,nameStr]=parseFullFileName(fullFileName)

            [pathStr,nameStr,extStr]=fileparts(fullFileName);

            nameStr=[nameStr,extStr];



            function fullFiles=i_resolveFiles(rootDirectory,files,description,searchDirectories,isResolveFilesChkStrict)








                processDollarAndSeps=true;
                [fullFiles,errorStrs]=sf('Private','tokenize',rootDirectory,files,description,searchDirectories,...
                processDollarAndSeps,isResolveFilesChkStrict);

                if~isempty(errorStrs)

                    CGXE.Utils.reportTokenizerDiagnostic(errorStrs,'RTW:buildProcess:CustomCodeTokenizeError');
                end



                function newSearchDirectories=do_extract_relevant_dirs(rootDirectory,searchDirectories,customCodeString)

                    newSearchDirectories=sf('Private','extract_relevant_dirs',rootDirectory,searchDirectories,customCodeString);


                    function found=i_folderContainsHeaderFiles(folder)


                        headerExtsExpr='\.((h)|(hpp))$';

                        d=dir(folder);


                        regexpResult=regexpi({d.name},headerExtsExpr,'once');

                        found=~all(cellfun(@isempty,regexpResult));
