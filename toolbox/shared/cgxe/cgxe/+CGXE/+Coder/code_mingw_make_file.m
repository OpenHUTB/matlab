function code_mingw_make_file(fileNameInfo,buildInfo,modelName,targetName,...
    targetInfo)




    import CGXE.Coder.*;
    if isequal(targetName,'cgxe')
        [codingLibrary,codingMakeDebug]=deal(false);
    else
        codingLibrary=targetInfo.codingLibrary;
        codingMakeDebug=targetInfo.codingMakeDebug;
    end
    gencpp=targetInfo.gencpp;
    code_model_objlist_file(fileNameInfo,buildInfo);

    fileName=fullfile(fileNameInfo.targetDirName,fileNameInfo.makeBatchFile);
    file=fopen(fileName,'Wt');
    if file<3
        construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
    end
    create_mexopts_caller_bat_file(file,fileNameInfo);
    fprintf(file,'gmake SHELL="cmd" -f %s\n',fileNameInfo.mingwMakeFile);

    fclose(file);

    fileName=fullfile(fileNameInfo.targetDirName,fileNameInfo.mingwMakeFile);

    file=fopen(fileName,'Wt','n',matlab.internal.i18n.locale.default.Encoding);
    if file<3
        construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
    end

    DOLLAR='$';
    fprintf(file,'#--------------------------- Tool Specifications -------------------------\n');
    fprintf(file,'#\n');
    fprintf(file,'# Modify the following macros to reflect the tools you wish to use for\n');
    fprintf(file,'# compiling and linking your code.\n');
    fprintf(file,'#\n');
    if(~isempty(fileNameInfo.userMakefiles))
        for i=1:length(fileNameInfo.userMakefiles)
            fprintf(file,'include $fileNameInfo.userMakefiles{i}\n');
        end
    end
    mexExec=fullfile(matlabroot,'bin','win64','mex.exe');
    mexCFlag='-R2018a';
    if(codingMakeDebug)
        fprintf(file,'CC = "%s" %s -g\n',mexExec,mexCFlag);
    else
        fprintf(file,'CC = "%s" %s\n',mexExec,mexCFlag);
    end
    if gencpp
        fprintf(file,'LD = %s(CC) -f "%s"\n',DOLLAR,targetInfo.mexopt);
    else
        fprintf(file,'LD = %s(CC)\n',DOLLAR);
    end
    fprintf(file,' \n');
    fprintf(file,'MODEL     = %s\n',modelName);
    fprintf(file,'TARGET      = %s\n',targetName);

    moduleSrcs=getCatString(getEscapedSourceFiles(buildInfo,false,true,'MODULE_SRCS'));
    fprintf(file,'MODULE_SRCS   = %s\n',moduleSrcs);

    modelSrc=getCatString(getEscapedSourceFiles(buildInfo,false,true,'MODEL_SRC'));
    fprintf(file,'MODEL_SRC  = %s\n',modelSrc);
    modelReg=getCatString(getEscapedSourceFiles(buildInfo,false,true,'MODEL_REG'));
    fprintf(file,'MODEL_REG = %s\n',modelReg);

    fprintf(file,'MAKEFILE    = %s\n',fileNameInfo.mingwMakeFile);

    fprintf(file,'MATLAB_ROOT  = %s\n',fullfile(sf('Root'),'..','..','..'));
    fprintf(file,'BUILDARGS   = \n');


    fprintf(file,'#------------------------------ Include/Lib Path ------------------------------\n');
    fprintf(file,' \n');
    userIncludeDirString='';
    userIncludeDirs=getIncludePaths(buildInfo,true,'USER_INCLUDES');
    if~isempty(userIncludeDirs)
        for i=1:length(userIncludeDirs)
            path=userIncludeDirs{i};
            userIncludeDirString=[userIncludeDirString,'-I"',path,'" '];%#ok<AGROW>
        end
    end
    fprintf(file,'USER_INCLUDES = %s\n',userIncludeDirString);

    auxIncludeDirString='';
    auxincludePaths=getIncludePaths(buildInfo,true,'AUX_INCLUDES');
    if~isempty(auxincludePaths)
        for i=1:length(auxincludePaths)
            path=auxincludePaths{i};
            auxIncludeDirString=[auxIncludeDirString,'-I"',path,'" '];%#ok<AGROW>
        end
    end

    fprintf(file,'AUX_INCLUDES = %s\n',auxIncludeDirString);

    mlslsfInclude=getIncludePaths(buildInfo,true,{'ML_INCLUDES','SL_INCLUDES','SF_INCLUDES'});
    fprintf(file,'MLSLSF_INCLUDES  = \\\n');
    for i=1:numel(mlslsfInclude)-1
        fprintf(file,'    -I"%s" \\\n',mlslsfInclude{i});
    end
    fprintf(file,'    -I"%s" \n',mlslsfInclude{end});
    fprintf(file,'\n');
    thirdPartyIncludes=getIncludePaths(buildInfo,true,{},{'USER_INCLUDES','AUX_INCLUDES',...
    'ML_INCLUDES','SL_INCLUDES','SF_INCLUDES'});
    thirdPartyIncludesString='';
    thirdPartyIncludes=CGXE.Utils.fix_windows_paths_for_make_file(thirdPartyIncludes);
    for i=1:length(thirdPartyIncludes)
        path=thirdPartyIncludes{i};
        thirdPartyIncludesString=[thirdPartyIncludesString,'-I"',path,'" '];%#ok<AGROW>
    end
    fprintf(file,'THIRD_PARTY_INCLUDES = %s\n',thirdPartyIncludesString);
    fprintf(file,'\n');
    fprintf(file,'INCLUDE_PATH = %s(USER_INCLUDES) %s(AUX_INCLUDES) %s(MLSLSF_INCLUDES) %s(COMPILER_INCLUDES) %s(THIRD_PARTY_INCLUDES)\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR);
    fprintf(file,' \n');

    fprintf(file,'#----------------- Compiler and Linker Options --------------------------------\n');
    fprintf(file,' \n');
    fprintf(file,'# Optimization Options\n');

    fprintf(file,' \n');
    fprintf(file,'CC_OPTS = %s %s\n',getCatString(buildInfo.getCompileFlags),getCatString(buildInfo.getDefines));

    fprintf(file,'CPP_REQ_DEFINES = -DMATLAB_MEX_FILE\n');
    fprintf(file,' \n');
    fprintf(file,'# Uncomment this line to move warning level to W4\n');
    fprintf(file,'# cflags = %s(cflags:W3=W4)\n',DOLLAR);
    fprintf(file,'CFLAGS = %s(CPP_REQ_DEFINES) %s(INCLUDE_PATH) CFLAGS="%s%sCFLAGS %s(CC_OPTS)"\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR);
    fprintf(file,' \n');
    fprintf(file,'LDFLAGS = %s\n',getCatString(buildInfo.getLinkFlags));
    fprintf(file,' \n');
    fprintf(file,'AUXLDFLAGS = %s\n',getCatString(buildInfo.getLinkFlags('AUXLDFLAGS')));

    fprintf(file,'#----------------------------- Source Files -----------------------------------\n');
    fprintf(file,' \n');
    thirdPartyExcludeGroups={'MODULE_SRCS','MODEL_SRC','MODEL_REG','USER_SRCS','AUX_SRCS'};
    thirdPartySources=buildInfo.getSourceFiles(true,true,{},thirdPartyExcludeGroups);


    thirdPartySourcePaths=buildInfo.getSourcePaths(true);
    for i=1:length(thirdPartySources)
        thirdPartySources{i}=CGXE.Utils.tokenizeFileFromModel(thirdPartySources{i},modelName,thirdPartySourcePaths);
    end

    tpSrcString=getCatString(setUnixFileSep(thirdPartySources));
    fprintf(file,'THIRD_PARTY_SRCS = %s  \n',tpSrcString);

    fprintf(file,'REQ_SRCS  = %s(MODEL_SRC) %s(MODEL_REG) %s(MODULE_SRCS) %s(THIRD_PARTY_SRCS) \n',DOLLAR,DOLLAR,DOLLAR,DOLLAR);
    fprintf(file,'\n');
    userSources=getEscapedSourceFiles(buildInfo,true,true,'USER_SRCS');

    if(~isempty(userSources))
        fprintf(file,'USER_OBJS    = \\\n');
        for i=1:length(userSources)
            [~,nameStr]=fileparts(userSources{i});
            objStr=[nameStr,'.obj'];
            fprintf(file,'		%s \\\n',objStr);
        end
    else
        fprintf(file,'USER_OBJS =\n');
    end
    fprintf(file,'\n');
    auxSources=getEscapedSourceFiles(buildInfo,true,true,'AUX_SRCS');
    if~isempty(auxSources)
        fprintf(file,'AUX_ABS_OBJS = \\\n');
        for i=1:numel(auxSources)
            [~,nameStr]=fileparts(auxSources{i});
            objStr=[nameStr,'.obj'];
            fprintf(file,'		%s \\\n',objStr);
        end
        fprintf(file,'\n');
    else
        fprintf(file,'AUX_ABS_OBJS =\n');
    end

    fprintf(file,'\n');

    fprintf(file,'REQ_OBJS = %s(REQ_SRCS:.cpp=.obj)\n',DOLLAR);
    fprintf(file,'REQ_OBJS2 = %s(REQ_OBJS:.c=.obj)\n',DOLLAR);
    fprintf(file,'OBJS = %s(REQ_OBJS2) %s(USER_OBJS) %s(AUX_ABS_OBJS) %s(THIRD_PARTY_OBJS)\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR);
    fprintf(file,'OBJLIST_FILE = %s\n',fileNameInfo.objListFile);

    fprintf(file,'SFCLIB = %s\n',getLinkObjStringForGroup(buildInfo,'SFCLIB'));

    fprintf(file,'AUX_LNK_OBJS = %s\n',getLinkObjStringForGroup(buildInfo,'AUX_LNK_OBJS'));
    fprintf(file,'USER_LIBS = %s\n',getLinkObjStringForGroup(buildInfo,'USER_LIBS'));
    fprintf(file,'PARLIB = %s\n',getLinkObjStringForGroup(buildInfo,'PARLIB'));

    excludeGroups={'SFCLIB','USER_LIBS','LINK_MACHINE_LIBS',...
    'LINK_MACHINE_OBJLIST','TMWLIB','PARLIB'};

    userGroups={};
    if codingLibrary
        libObjListfile=['lib_',fileNameInfo.objListFile];
        code_append_user_external_link_flags_for_library(libObjListfile,fileNameInfo.targetDirName,buildInfo);
    else
        libObjListfile=fileNameInfo.objListFile;
    end

    fprintf(file,' \n');
    fprintf(file,'#--------------------------------- Rules --------------------------------------\n');
    fprintf(file,' \n');
    if codingLibrary

        fprintf(file,'DO_RANLIB = ranlib %s(MODEL)_%s(TARGET).lib\n',DOLLAR,DOLLAR);
        fprintf(file,' \n');
        fprintf(file,'%s(MODEL)_%s(TARGET).lib :  %s(OBJS) %s(SFCLIB) %s(AUX_LNK_OBJS)\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR);
        fprintf(file,'	@echo ### Linking ...\n');
        fprintf(file,'	ar ruv %s(MODEL)_%s(TARGET).lib %s(USER_LIBS) %s(SFCLIB) %s(PARLIB) %s(IPPLIB) %s(THIRD_PARTY_LIBS) @%s(OBJLIST_FILE)\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR);

        fprintf(file,'	%s(DO_RANLIB)\n',DOLLAR);

        code_append_libs_to_objlist_file_mingw(libObjListfile,...
        fileNameInfo.targetDirName,buildInfo,userGroups,excludeGroups);
        CGXE.Coder.code_append_syslibs_to_objlist_file(libObjListfile,fileNameInfo.targetDirName,...
        buildInfo,modelName);
    else
        CGXE.Coder.code_append_syslibs_to_objlist_file(libObjListfile,fileNameInfo.targetDirName,...
        buildInfo,modelName);
        code_append_libs_to_objlist_file_mingw(libObjListfile,...
        fileNameInfo.targetDirName,buildInfo,'LINK_MACHINE_LIBS');



        code_append_libs_to_objlist_file_mingw(libObjListfile,...
        fileNameInfo.targetDirName,buildInfo,userGroups,excludeGroups);
        code_append_libs_to_objlist_file_mingw(libObjListfile,...
        fileNameInfo.targetDirName,buildInfo,'TMWLIB');
        code_append_libs_to_objlist_file_mingw(libObjListfile,...
        fileNameInfo.targetDirName,buildInfo,'LINK_MACHINE_OBJLIST');

        fprintf(file,'MEX_FILE_NAME = %s(MODEL)_%s(TARGET).%s\n',DOLLAR,DOLLAR,mexext);

        fprintf(file,' \n');
        fprintf(file,' %s(MEX_FILE_NAME): %s(MAKEFILE) %s(OBJS) %s(SFCLIB) %s(AUX_LNK_OBJS)\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR);
        fprintf(file,'	@echo ### Linking ...\n');
        fprintf(file,'	%s(LD) -silent LD="%s%sMINGWROOT\\bin\\g++" LDFLAGS="%s%sLDFLAGS %s(LDFLAGS) %s(AUXLDFLAGS)" -output %s(MEX_FILE_NAME) @%s(OBJLIST_FILE) %s(USER_LIBS) %s(SFCLIB) %s(PARLIB) %s(IPPLIB) %s(THIRD_PARTY_LIBS) \n',DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR);

    end
    fprintf(file,'%%.obj :    %%.c\n');
    fprintf(file,'	%s(CC) -c %s(CFLAGS) %s<\n',DOLLAR,DOLLAR,DOLLAR);
    fprintf(file,'\n');
    fprintf(file,'%%.obj :    %%.cpp\n');
    fprintf(file,'	%s(CC) -c %s(CFLAGS) %s<\n',DOLLAR,DOLLAR,DOLLAR);
    fprintf(file,'\n');
    for i=1:length(userSources)
        objFileName=code_pc_change_ext(userSources{i},'obj');
        fprintf(file,'%s :	%s\n',objFileName,userSources{i});
        fprintf(file,'	%s(CC) -c %s(CFLAGS) %s<\n',DOLLAR,DOLLAR,DOLLAR);
    end

    fclose(file);

    function paths=getIncludePaths(buildInfo,varargin)
        paths=buildInfo.getIncludePaths(varargin{:});
        paths=regexprep(paths,'#','\\#');

        function paths=getEscapedSourceFiles(buildInfo,varargin)

            paths=setUnixFileSep(buildInfo.getSourceFiles(varargin{:}));

            function paths=setUnixFileSep(paths)
                if iscell(paths)
                    for i=1:numel(paths)
                        paths{i}=getAltPath(paths{i});
                    end
                end
                paths=strrep(paths,'\','/');

                paths=regexprep(paths,'([^\\])#','$1\\#');


                function result=code_pc_change_ext(filename,ext)

                    [~,name_str]=fileparts(filename);

                    result=[name_str,'.',ext];

                    function linkObjStr=getLinkObjStringForGroup(buildInfo,group,excludeGroups,delim)


                        if nargin<3
                            excludeGroups={};
                        end
                        if nargin<4
                            delim='';
                        end
                        linkObjs=buildInfo.getLinkObjects(group,excludeGroups);
                        linkObjStr='';
                        for iL=1:numel(linkObjs)
                            currLinkObjPath=linkObjs(iL).Path;
                            currLinkObjPath=strrep(currLinkObjPath,'$(MATLAB_ROOT)',matlabroot);
                            fullfileName=fullfile(currLinkObjPath,linkObjs(iL).Name);
                            if isequal(group,'LINK_MACHINE_OBJLIST')
                                linkObjStr=fileread(fullfileName);
                                linkObjStr=regexprep(linkObjStr,'[\n\r]+',sprintf('\n'));
                            elseif~isempty(strfind(linkObjs(iL).Name,'mwipp'))
                                [~,libname]=fileparts(linkObjs(iL).Name);
                                linkObjStr=[linkObjStr,'"-L',currLinkObjPath,'" "-l',libname,'" ',delim];%#ok<AGROW>
                            else
                                linkObjStr=[linkObjStr,'"',fullfile(currLinkObjPath,linkObjs(iL).Name),'" ',delim];%#ok<AGROW>
                            end
                        end
                        linkObjStr=strtrim(linkObjStr);

                        function str=getCatString(incell)

                            str=sprintf('%s ',incell{:});
                            if~isempty(str)
                                str(end)=[];
                            end

                            function paths=getAltPath(inpath)

                                if isdir(inpath)
                                    paths=cgxeprivate('cgxeAltPathName',inpath);
                                else
                                    [pathStr,nameStr,ext]=fileparts(inpath);
                                    if~isempty(pathStr)
                                        paths=cgxeprivate('cgxeAltPathName',pathStr);
                                        paths=[paths,filesep,nameStr,ext];
                                    else
                                        paths=inpath;
                                    end
                                end

                                function code_append_libs_to_objlist_file_mingw(objListFile,targetDirName,...
                                    buildInfo,group,excludeGroups)
                                    if nargin<5
                                        excludeGroups={};
                                    end
                                    fileName=fullfile(targetDirName,objListFile);
                                    file=fopen(fileName,'At');
                                    if file<3
                                        construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
                                    end
                                    linkObjStr=getLinkObjStringForGroup(buildInfo,group,excludeGroups,sprintf('\n'));
                                    fprintf(file,'%s\n',linkObjStr);
                                    fclose(file);
