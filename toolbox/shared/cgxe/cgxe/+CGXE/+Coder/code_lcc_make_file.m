function code_lcc_make_file(fileNameInfo,buildInfo,modelName)






    if(strcmp(computer,'PCWIN64'))
        lccRoot=fullfile(matlabroot,'sys','lcc64','lcc64');
        projectInfo.cc=[lccRoot,'\bin\lcc64.exe'];
        projectInfo.ld=[lccRoot,'\bin\lcclnk64.exe'];
        projectInfo.libcmd=[lccRoot,'\bin\lcclib64.exe'];
    else
        lccRoot=fullfile(matlabroot,'sys','lcc');
        projectInfo.cc=[lccRoot,'\bin\lcc.exe'];
        projectInfo.ld=[lccRoot,'\bin\lcclnk.exe'];
        projectInfo.libcmd=[lccRoot,'\bin\lcclib.exe'];
    end

    targetName='cgxe';
    fileName=fullfile(fileNameInfo.targetDirName,fileNameInfo.makeBatchFile);
    file=fopen(fileName,'Wt');
    if file<0
        throw(MException('Simulink:cgxe:FailedToCreateFile',fileName));
    end
    fprintf(file,'"%s\\bin\\lccmake.exe" -f %s\n',lccRoot,fileNameInfo.lccMakeFile);
    fclose(file);

    projectInfo.targetDirName=fileNameInfo.targetDirName;
    projectInfo.handlesSpaces=1;
    projectInfo.nameDirective='-o ';

    projectInfo.cflags=[getCatString(buildInfo.getCompileFlags),getCatString(buildInfo.getDefines)];
    projectInfo.ldflags=getCatString(buildInfo.getLinkFlags);

    projectInfo.libflags='';

    projectInfo.makeFileName=fileNameInfo.lccMakeFile;

    thirdPartyExcludes={'ML_INCLUDES','SL_INCLUDES','USER_INCLUDES'};
    projectInfo.includeDirs=buildInfo.getIncludePaths(true);
    projectInfo.includeDirs=buildInfo.getIncludePaths(true,thirdPartyExcludes);
    thirdPartyIncludes=buildInfo.getIncludePaths(true,{},thirdPartyExcludes);
    if~isempty(thirdPartyIncludes)
        thirdPartyIncludes=CGXE.Utils.fix_windows_paths_for_make_file(thirdPartyIncludes);
        projectInfo.includeDirs=[projectInfo.includeDirs,thirdPartyIncludes];
    end

    libraries=arrayfun(@(BI)fullfile(BI.Path,BI.Name),buildInfo.getLinkObjects,'UniformOutput',false)';
    projectInfo.libraries=strrep(libraries,'$(MATLAB_ROOT)',matlabroot);

    sourceGroups={'MODEL_SRC','MODULE_SRCS','MODEL_REG',...
    'COMPILER_SRC','USER_SRCS'};
    projectInfo.sourceFiles=buildInfo.getSourceFiles(true,true,sourceGroups);
    for i=1:numel(projectInfo.sourceFiles)
        [pathStr,nameStr,ext]=fileparts(projectInfo.sourceFiles{i});
        if isequal(pathStr,projectInfo.targetDirName)


            projectInfo.sourceFiles{i}=[nameStr,ext];
        end
    end

    thirdPartyExcludeGroups=sourceGroups;
    projectInfo.thirdPartySrcs=buildInfo.getSourceFiles(true,true,{},...
    thirdPartyExcludeGroups);
    projectInfo.thirdPartySourcePaths=buildInfo.getSourcePaths(true);

    projectInfo.outputFileName=[modelName,'_',targetName,'.',mexext];

    projectInfo.preLinkCommand='';
    projectInfo.postLinkCommand='';

    lcc_make_gen(projectInfo,fileNameInfo,buildInfo,modelName);

    function lcc_make_gen(projectInfo,fileNameInfo,buildInfo,modelName)


        projectInfo=escapeHashInDirs(projectInfo);

        fileName=fullfile(projectInfo.targetDirName,projectInfo.makeFileName);
        file=fopen(fileName,'Wt');
        if file<0
            throw(MException('Simulink:cgxe:FailedToCreateFile',fileName));
        end

        if(projectInfo.handlesSpaces)
            quoteChar='"';
        else
            quoteChar='';
        end

        DOLLAR='$';
        fprintf(file,'CC     = %s%s%s\n',quoteChar,projectInfo.cc,quoteChar);
        fprintf(file,'LD     = %s%s%s\n',quoteChar,projectInfo.ld,quoteChar);
        fprintf(file,'LIBCMD = %s%s%s\n',quoteChar,projectInfo.libcmd,quoteChar);
        fprintf(file,'CFLAGS = %s\n',projectInfo.cflags);
        fprintf(file,'LDFLAGS = %s\n',projectInfo.ldflags);
        fprintf(file,'LIBFLAGS = %s\n',projectInfo.libflags);
        fprintf(file,'\n');

        projectInfo.objectFiles=[projectInfo.sourceFiles,projectInfo.thirdPartySrcs];
        for i=1:length(projectInfo.objectFiles)
            sourceFile=projectInfo.objectFiles{i};
            objectFile=[sourceFile(1:end-1),'obj'];
            fileSeps=find(objectFile=='\');
            if(~isempty(fileSeps))
                objectFile=objectFile(fileSeps(end)+1:end);
            end
            projectInfo.objectFiles{i}=objectFile;
        end

        includeDirString='';
        if(~isempty(projectInfo.includeDirsEscaped))
            for i=1:length(projectInfo.includeDirsEscaped)
                includeDirString=[includeDirString,' -I',quoteChar,projectInfo.includeDirsEscaped{i},quoteChar,' '];
            end
        end

        projectInfo.objectListFile=[projectInfo.makeFileName,'o'];
        projectInfo.objectListFilePath=fullfile(projectInfo.targetDirName,projectInfo.objectListFile);
        code_lcc_objlist_file(projectInfo.objectListFilePath,projectInfo.objectFiles,projectInfo.libraries,quoteChar);
        fileNameInfo.objListFile=projectInfo.objectListFile;
        CGXE.Coder.code_append_syslibs_to_objlist_file(fileNameInfo.objListFile,...
        fileNameInfo.targetDirName,buildInfo,modelName);
        fprintf(file,'OBJECTS = \\\n');
        for i=1:length(projectInfo.objectFiles)
            fprintf(file,'	%s%s%s\\\n',quoteChar,projectInfo.objectFiles{i},quoteChar);
        end
        for i=1:length(projectInfo.librariesEscaped)
            fprintf(file,'	%s%s%s\\\n',quoteChar,projectInfo.librariesEscaped{i},quoteChar);
        end
        fprintf(file,'\n');
        fprintf(file,'INCLUDE_PATH=%s\n',includeDirString);
        fprintf(file,' \n');
        fprintf(file,'\n');
        projectInfo.preLinkCommand='';
        projectInfo.postLinkCommand='';

        fprintf(file,'%s : %s(MAKEFILE) %s(OBJECTS)\n',projectInfo.outputFileName,DOLLAR,DOLLAR);
        if(~isempty(projectInfo.preLinkCommand))
            fprintf(file,'	%s\n',projectInfo.preLinkCommand);
        end
        fprintf(file,'	%s(LD) %s(LDFLAGS) %s%s @%s\n',DOLLAR,DOLLAR,projectInfo.nameDirective,projectInfo.outputFileName,projectInfo.objectListFile);
        if(~isempty(projectInfo.postLinkCommand))
            fprintf(file,'	%s\n',projectInfo.postLinkCommand);
        end

        numSrcs=length(projectInfo.sourceFilesEscaped);
        for i=1:numSrcs
            fprintf(file,'%s :	%s%s%s\n',projectInfo.objectFiles{i},quoteChar,projectInfo.sourceFilesEscaped{i},quoteChar);
            fprintf(file,'	%s(CC) %s(CFLAGS) %s(INCLUDE_PATH) %s%s%s\n',DOLLAR,DOLLAR,DOLLAR,quoteChar,projectInfo.sourceFilesEscaped{i},quoteChar);
        end

        for i=1:length(projectInfo.thirdPartySrcsEscaped)
            [fullSrcName,srcFileName]=CGXE.Utils.tokenizeFileFromModel(projectInfo.thirdPartySrcsEscaped{i},...
            modelName,projectInfo.thirdPartySourcePaths);
            objFileName=[srcFileName,'.obj'];
            fprintf(file,'%s :	"%s"\n',objFileName,fullSrcName);
            fprintf(file,'	%s(CC) %s(CFLAGS) %s(INCLUDE_PATH) "%s"\n',DOLLAR,DOLLAR,DOLLAR,fullSrcName);
        end

        fclose(file);

        function code_lcc_objlist_file(objListFile,objectFiles,libraryFiles,quoteChar)

            fileName=objListFile;
            file=fopen(fileName,'Wt');
            if file<0
                throw(MException('Simulink:cgxe:FailedToCreateFile',fileName));
            end

            for i=1:length(objectFiles)
                fprintf(file,'%s%s%s\n',quoteChar,objectFiles{i},quoteChar);
            end
            for i=1:length(libraryFiles)
                fprintf(file,'%s%s%s\n',quoteChar,libraryFiles{i},quoteChar);
            end

            fclose(file);

            function projectInfo=escapeHashInDirs(projectInfo)




                projectInfo.includeDirsEscaped=strrep(projectInfo.includeDirs,'#','\#');
                projectInfo.librariesEscaped=strrep(projectInfo.libraries,'#','\#');
                projectInfo.sourceFilesEscaped=strrep(projectInfo.sourceFiles,'#','\#');
                projectInfo.thirdPartySrcsEscaped=strrep(projectInfo.thirdPartySrcs,'#','\#');

                function str=getCatString(incell)

                    str=sprintf('%s ',incell{:});
                    if~isempty(str)
                        str(end)=[];
                    end
