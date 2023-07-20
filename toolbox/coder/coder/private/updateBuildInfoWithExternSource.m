function reservedFileNames=updateBuildInfoWithExternSource(bldParams)






    apply3plToBuildInfo(bldParams.buildInfo,bldParams.configInfo,bldParams.project.BldDirectory,bldParams.tplUseClassNames);

    cfgSettings=bldParams.configInfo;
    customCodeGroup='CustomCode';
    if isa(cfgSettings,'coder.MexCodeConfig')||isa(cfgSettings,'coder.CodeConfig')
        custCodeFiles=resolve_custom_code(...
        cfgSettings.CustomInclude,cfgSettings.CustomSource,cfgSettings.CustomLibrary,bldParams.buildInfo);
    else
        custCodeFiles=resolve_custom_code('','','',bldParams.buildInfo);
    end

    if~isempty(custCodeFiles.parsedIncludePaths)
        bldParams.buildInfo.addIncludePaths(custCodeFiles.parsedIncludePaths,customCodeGroup);
    end
    bldParams.buildInfo.addSourcePaths(custCodeFiles.parsedSrcPaths,customCodeGroup);

    depSrcFiles={};
    depSrcFilesPaths={};
    depSrcFilesGroups={};


    if~isempty(custCodeFiles.parsedSrcFiles)
        [custCodeFilesPaths,custCodeFileNames]=cellfun(@parseFullFileName,custCodeFiles.parsedSrcFiles,'UniformOutput',false);

        custCodeFilesGroups(1:length(custCodeFileNames))={customCodeGroup};

        depSrcFiles=[depSrcFiles,custCodeFileNames];
        depSrcFilesPaths=[depSrcFilesPaths,custCodeFilesPaths];
        depSrcFilesGroups=[depSrcFilesGroups,custCodeFilesGroups];
    end
    bldParams.buildInfo.addSourceFiles(depSrcFiles,depSrcFilesPaths,depSrcFilesGroups);


    if(~isempty(bldParams.configInfo.GpuConfig)&&bldParams.configInfo.GpuConfig.Enabled)
        codingTarget=getCodingTargetFromConfig(bldParams.configInfo);
        coder.gpu.updateGpuBuildInfo(bldParams,codingTarget);
    end


    if~isempty(custCodeFiles.parsedLibFiles)
        [depLibsPaths,depLibs]=cellfun(@parseFullFileName,custCodeFiles.parsedLibFiles,'UniformOutput',false);


        bldParams.buildInfo.addLibraries(depLibs,depLibsPaths,1000,false,true,customCodeGroup);
    end

    externSource=bldParams.buildInfo.getSourceFiles(false,false);

    reservedFileNames=cell(1,numel(externSource));

    for i=1:numel(externSource)
        [~,f,~]=fileparts(externSource{i});
        reservedFileNames{i}=f;
    end
end


function custCodeFiles=resolve_custom_code(userIncludePaths,userSrcFiles,userLibFiles,buildInfo)
    modelPath=pwd;



    parsedSearchPath=...
    tokenize(modelPath,userIncludePaths,'custom include directory paths string',{},pathsep);


    parsedSrcFiles=...
    tokenize(modelPath,userSrcFiles,'custom source files string',unique([parsedSearchPath,buildInfo.getSourcePaths(true)]),pathsep);


    parsedLibFiles=...
    tokenize(modelPath,userLibFiles,'custom libraries string',unique([parsedSearchPath,buildInfo.getLibraryPaths]),pathsep);


    numParsedSrcFiles=length(parsedSrcFiles);
    parsedSrcPaths=cell(1,numParsedSrcFiles);
    parsedSrcFileNames=cell(1,numParsedSrcFiles);
    for i=1:numParsedSrcFiles
        [parsedSrcPaths{i},parsedSrcFileNames{i}]=parseFullFileName(parsedSrcFiles{i});
    end


    custCodeFiles.parsedIncludePaths=parsedSearchPath;
    custCodeFiles.parsedLibFiles=parsedLibFiles;
    custCodeFiles.parsedSrcFiles=parsedSrcFiles;
    custCodeFiles.parsedSrcPaths=parsedSrcPaths;
    custCodeFiles.parsedSrcFileNames=parsedSrcFileNames;
end


function tokenList=tokenize(rootDirectory,str,description,searchDirectories,aSep)
    tokenList={};
    if(isempty(str))
        return;
    end
    tokens=tokenizeStr(str,aSep);
    for idx=1:numel(tokens)
        token=tokens{idx};
        if token(1)=='.'

            token=fullfile(rootDirectory,token);
        else
            if ispc&&length(token)>=2

                isAnAbsolutePath=(token(2)==':')||startsWith(token,'\\');
            else

                isAnAbsolutePath=startsWith(token,'/');
            end
            if~isAnAbsolutePath


                if~isempty(searchDirectories)

                    searchDirectories{end+1}=rootDirectory;%#ok<AGROW>
                    found=0;
                    for i=1:length(searchDirectories)
                        fullToken=fullfile(searchDirectories{i},token);
                        if isfile(fullToken)
                            found=1;
                            break;
                        end
                    end
                    if found
                        token=fullToken;
                    else
                        fileList=strjoin(searchDirectories,newline);
                        error(message('Coder:buildProcess:fileNotFound',...
                        token,description,fileList));
                    end
                else
                    token=fullfile(rootDirectory,token);
                end
            end
        end
        tokenList{end+1}=token;%#ok
    end

    tokenList=unique(tokenList,'stable');
end


function[pathStr,nameStr]=parseFullFileName(fullFileName)
    [pathStr,nameStr,extStr]=fileparts(fullFileName);
    nameStr=[nameStr,extStr];
end


function tokens=tokenizeStr(str,aSep)
    result=strsplit(str,{aSep,newline});

    tokens={};
    for i=1:numel(result)
        t=strtrim(result{i});
        if~isempty(t)
            if t(1)=='"'
                t=t(2:end-1);
            end
            if~isempty(t)
                tokens{end+1}=t;%#ok<AGROW>
            end
        end
    end
end
