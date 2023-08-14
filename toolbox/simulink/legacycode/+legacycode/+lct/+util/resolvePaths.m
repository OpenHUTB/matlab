function[pathInfo,sfunSourceNotFound]=resolvePaths(infoStruct,isSimTarget,currDir,mlPaths)






    narginchk(1,4);
    nargoutchk(0,6);

    if nargin<2
        isSimTarget=true;
    end

    if nargin<3||isempty(currDir)
        currDir=pwd;
    else
        validateattributes(currDir,...
        {'char','string'},{'scalartext'},'legacycode.lct.util.resolvePaths','',2);
    end

    if nargin<4

        mlPaths=legacycode.lct.util.getSearchPath();
    end

    sfunSourceNotFound=false;




    lang='C';
    isSingleCPPMexFile=false;
    if isfield(infoStruct,'Options')||isprop(infoStruct,'Options')
        lang=char(infoStruct.Options.language);
        isSingleCPPMexFile=infoStruct.Options.singleCPPMexFile~=0;
        stubSimBehavior=infoStruct.Options.stubSimBehavior;
    else
        if isfield(infoStruct,'Language')
            lang=char(infoStruct.Language);
        end
        if isfield(infoStruct,'singleCPPMexFile')
            isSingleCPPMexFile=infoStruct.singleCPPMexFile~=0;
        end
        stubSimBehavior=false;
    end

    if strcmpi(lang,'C')&&~isSingleCPPMexFile
        fext='.c';
    else
        fext='.cpp';
    end


    fcnName=char(infoStruct.SFunctionName);
    fcnNameWithExt=[fcnName,fext];
    if legacycode.lct.util.isfile(fcnNameWithExt)
        pathToSFun=pwd;
    else
        pathToSFun=fileparts(which(fcnNameWithExt));
    end
    if isempty(pathToSFun)





        hasFailedAgain=true;
        if isSingleCPPMexFile
            newFext='.c';
            if legacycode.lct.util.isfile([fcnName,newFext])
                pathToSFun=pwd;
            else
                pathToSFun=fileparts(which([fcnName,newFext]));
            end
            if~isempty(pathToSFun)

                fext=newFext;
                hasFailedAgain=false;
            end
        end






        if hasFailedAgain
            pathToSFun=fileparts(which([fcnName,'.',mexext]));
            if~isempty(pathToSFun)
                hasFailedAgain=false;
                sfunSourceNotFound=true;
            end
        end

        if hasFailedAgain
            error(message('Simulink:tools:LCTErrorCannotFindSourceFile',fcnNameWithExt));
        end
    end


    defaultPaths=RTW.unique([{pathToSFun};{currDir}]);
    allPaths=RTW.unique([defaultPaths;mlPaths]);


    if~strcmp(currDir,pathToSFun)
        fullFileName=fullfile(pathToSFun,fcnName);
    else
        fullFileName=fcnName;
    end
    pathInfo.SFunctionFileName=[fullFileName,fext];



    if stubSimBehavior
        incPaths={};
    else
        incPaths=cellstr(infoStruct.IncPaths(:));
        for jj=1:length(incPaths)
            [fullPath,found]=legacycode.lct.util.findPath(...
            legacycode.lct.util.fixPathSep(incPaths{jj}),allPaths);
            if found
                incPaths{jj}=fullPath;
            else
                error(message('Simulink:tools:LCTErrorCannotFindIncludePath',incPaths{jj}));
            end
        end
    end
    pathInfo.IncPaths=RTW.unique([incPaths;defaultPaths]);



    if stubSimBehavior
        srcPaths={};
    else
        srcPaths=cellstr(infoStruct.SrcPaths(:));
        for jj=1:length(srcPaths)
            [fullPath,found]=legacycode.lct.util.findPath(...
            legacycode.lct.util.fixPathSep(srcPaths{jj}),allPaths);
            if found
                srcPaths{jj}=fullPath;
            else
                error(message('Simulink:tools:LCTErrorCannotFindSourcePath',srcPaths{jj}));
            end
        end
    end

    if isSimTarget

        pathInfo.SrcPaths=RTW.unique([srcPaths;allPaths]);
        srcSearchPaths=pathInfo.SrcPaths;
    else


        pathInfo.SrcPaths=RTW.unique([srcPaths;defaultPaths]);
        srcSearchPaths=RTW.unique([pathInfo.SrcPaths;mlPaths]);
    end



    if stubSimBehavior
        sourceFiles={};
        pathToSourceFiles={};
    else
        sourceFiles=cellstr(infoStruct.SourceFiles(:));
        pathToSourceFiles=cell(length(sourceFiles),1);
        for jj=1:length(sourceFiles)
            [fullName,found]=legacycode.lct.util.findFile(...
            legacycode.lct.util.fixPathSep(sourceFiles{jj}),srcSearchPaths);
            if found
                sourceFiles{jj}=fullName;
                pathToSourceFiles{jj}=fileparts(fullName);
            else
                error(message('Simulink:tools:LCTErrorCannotFindSourceFile',sourceFiles{jj}));
            end
        end
    end
    pathInfo.SourceFiles=sourceFiles;


    pathToSourceFiles(cellfun(@isempty,pathToSourceFiles))=[];
    pathInfo.SrcPaths=RTW.unique([pathInfo.SrcPaths;pathToSourceFiles]);



    if stubSimBehavior
        libPaths={};
    else
        libPaths=cellstr(infoStruct.LibPaths(:));
        for jj=1:length(libPaths)
            [fullPath,found]=legacycode.lct.util.findPath(...
            legacycode.lct.util.fixPathSep(libPaths{jj}),allPaths);
            if found
                libPaths{jj}=fullPath;
            else
                error(message('Simulink:tools:LCTErrorCannotFindLibraryPath',libPaths{jj}));
            end
        end
    end
    pathInfo.LibPaths=RTW.unique([libPaths;allPaths]);



    if stubSimBehavior
        libFiles={};
    else
        if isSimTarget
            libFiles=infoStruct.HostLibFiles(:);
        else
            libFiles=infoStruct.TargetLibFiles(:);
        end
        libFiles=cellstr(libFiles);

        for jj=1:length(libFiles)
            [fullName,found]=legacycode.lct.util.findFile(...
            legacycode.lct.util.fixPathSep(libFiles{jj}),pathInfo.LibPaths);
            if found
                libFiles{jj}=fullName;
            else
                error(message('Simulink:tools:LCTErrorCannotFindLibraryFile',libFiles{jj}));
            end
        end
    end
    pathInfo.LibFiles=RTW.unique(libFiles);


