function code_msvc_make_file(buildInfo,fileNameInfo,modelName)





    import CGXE.Coder.*;

    code_model_objlist_file(fileNameInfo,buildInfo);
    code_append_syslibs_to_objlist_file(fileNameInfo.objListFile,...
    fileNameInfo.targetDirName,buildInfo,modelName);

    fileName=fullfile(fileNameInfo.targetDirName,fileNameInfo.makeBatchFile);

    file=fopen(fileName,'Wt');
    if file<0
        throw(MException('Simulink:cgxe:FailedToCreateFile',fileName));
    end
    create_mexopts_caller_bat_file(file,fileNameInfo);
    fprintf(file,'nmake -f %s\n',fileNameInfo.msvcMakeFile);
    fclose(file);

    fileName=fullfile(fileNameInfo.targetDirName,fileNameInfo.msvcMakeFile);
    file=fopen(fileName,'Wt');
    if file<0
        throw(MException('Simulink:cgxe:FailedToCreateFile',fileName));
    end

    codingDeveloper=false;
    DOLLAR='$';
    fprintf(file,'# ------------------- Required for MSVC nmake ---------------------------------\n');
    fprintf(file,'# This file should be included at the top of a MAKEFILE as follows:\n');
    fprintf(file,'\n');
    fprintf(file,'\n');
    if(strcmp(computer,'PCWIN64'))
        fprintf(file,'CPU = AMD64\n');
    end

    msCompilersWithWin32mak={'msvc100','msvcpp100',...
    'msvc90','msvcpp90',...
    'msvc80','msvcpp80',...
    'mssdk71','mssdk71cpp'};
    if ismember(fileNameInfo.compilerName,msCompilersWithWin32mak)

        fprintf(file,'!include <ntwin32.mak>\n');
    end
    fprintf(file,'\n');

    fprintf(file,'MODEL  = %s\n',modelName);
    fprintf(file,'TARGET = cgxe\n');

    moduleSrcs=getCatString(buildInfo.getSourceFiles(false,true,'MODULE_SRCS'));
    fprintf(file,'MODULE_SRCS 	= %s\n',moduleSrcs);
    modelSrc=getCatString(buildInfo.getSourceFiles(false,true,'MODEL_SRC'));
    fprintf(file,'MODEL_SRC	= %s\n',modelSrc);
    modelReg=getCatString(buildInfo.getSourceFiles(false,true,'MODEL_REG'));
    fprintf(file,'MODEL_REG = %s\n',modelReg);

    fprintf(file,'MAKEFILE    = %s\n',fileNameInfo.msvcMakeFile);

    fprintf(file,'MATLAB_ROOT	= %s\n',fileNameInfo.matlabRoot);
    fprintf(file,'BUILDARGS   =\n');

    fprintf(file,'\n');
    fprintf(file,'#--------------------------- Tool Specifications ------------------------------\n');
    fprintf(file,'#\n');
    fprintf(file,'#\n');
    fprintf(file,'MSVC_ROOT1 = %s(MSDEVDIR:SharedIDE=vc)\n',DOLLAR);
    fprintf(file,'MSVC_ROOT2 = %s(MSVC_ROOT1:SHAREDIDE=vc)\n',DOLLAR);
    fprintf(file,'MSVC_ROOT  = %s(MSVC_ROOT2:sharedide=vc)\n',DOLLAR);
    fprintf(file,'\n');
    fprintf(file,'# Compiler tool locations, CC, LD, LIBCMD:\n');
    fprintf(file,'CC     = cl.exe\n');
    fprintf(file,'LD     = link.exe\n');
    fprintf(file,'LIBCMD = lib.exe\n');

    fprintf(file,'#------------------------------ Include/Lib Path ------------------------------\n');
    fprintf(file,'\n');
    fprintf(file,'\n');
    userIncludeDirString='';
    userIncludeDirs=buildInfo.getIncludePaths(true,'USER_INCLUDES');
    for i=1:length(userIncludeDirs)
        thisIncDir=userIncludeDirs{i};
        if~isempty(regexp(thisIncDir,'^[a-zA-Z]+:$','once'))


            thisIncDir=[thisIncDir,'\.'];
        end
        userIncludeDirString=[userIncludeDirString,' /I "',thisIncDir,'"'];
    end
    fprintf(file,'USER_INCLUDES   = %s\n',userIncludeDirString);
    fprintf(file,'\n');

    mlslInclude=buildInfo.getIncludePaths(true,{'ML_INCLUDES','SL_INCLUDES'});
    fprintf(file,'MLSL_INCLUDES     = \\\n');
    numEle=numel(mlslInclude);
    for i=1:(numEle-1)
        fprintf(file,'    /I "%s" \\\n',mlslInclude{i});
    end
    fprintf(file,'    /I "%s"\n',mlslInclude{numEle});

    fprintf(file,'COMPILER_INCLUDES = /I "%s(MSVC_ROOT)\\include"\n',DOLLAR);
    fprintf(file,'\n');
    thirdPartyIncludeString='';
    thirdPartyincludePaths=buildInfo.getIncludePaths(true,{},{'ML_INCLUDES','SL_INCLUDES','USER_INCLUDES'});
    thirdPartyincludePaths=CGXE.Utils.fix_windows_paths_for_make_file(thirdPartyincludePaths);
    for i=1:length(thirdPartyincludePaths)
        thirdPartyIncludeString=[thirdPartyIncludeString,' /I "',thirdPartyincludePaths{i},'"'];
    end
    fprintf(file,'THIRD_PARTY_INCLUDES   = %s\n',thirdPartyIncludeString);

    fprintf(file,'INCLUDE_PATH = %s(MLSL_INCLUDES) %s(USER_INCLUDES) %s(THIRD_PARTY_INCLUDES)\n',DOLLAR,DOLLAR,DOLLAR);
    fprintf(file,'LIB_PATH     = "%s(MSVC_ROOT)\\lib"\n',DOLLAR);


    fprintf(file,'CFLAGS = %s %s\n',getCatString(buildInfo.getCompileFlags),getCatString(buildInfo.getDefines));
    fprintf(file,'LDFLAGS = %s\n',getCatString(buildInfo.getLinkFlags));

    fprintf(file,'#----------------------------- Source Files -----------------------------------\n');
    fprintf(file,'\n');
    userSources=buildInfo.getSourceFiles(true,true,'USER_SRCS');
    if(~isempty(userSources))
        fprintf(file,'USER_OBJS 	= \\\n');
        for i=1:length(userSources)
            [pathStr,nameStr]=fileparts(userSources{i});
            objStr=[nameStr,'.obj'];
            fprintf(file,'		"%s" \\\n',objStr);
        end
    else
        fprintf(file,'USER_OBJS =\n');
    end
    fprintf(file,'\n');

    auxSrcExcludeGroups={'MODULE_SRCS','MODEL_SRC','MODEL_REG','USER_SRCS'};

    thirdPartySources=buildInfo.getSourceFiles(true,true,{},auxSrcExcludeGroups);


    thirdPartySourcePaths=buildInfo.getSourcePaths(true);
    for i=1:length(thirdPartySources)
        thirdPartySources{i}=CGXE.Utils.tokenizeFileFromModel(thirdPartySources{i},modelName,thirdPartySourcePaths);
    end

    fprintf(file,'AUX_SRCS = %s  \n',getAltCatString(thirdPartySources));
    fprintf(file,'\n');
    fprintf(file,'REQ_SRCS  = %s(MODEL_SRC) %s(MODEL_REG) %s(MODULE_SRCS) %s(AUX_SRCS)\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR);
    fprintf(file,'REQ_OBJS = %s(REQ_SRCS:.cpp=.obj)\n',DOLLAR);
    fprintf(file,'REQ_OBJS2 = %s(REQ_OBJS:.c=.obj)\n',DOLLAR);
    fprintf(file,'OBJS = %s(REQ_OBJS2) %s(USER_OBJS) %s(AUX_ABS_OBJS)\n',DOLLAR,DOLLAR,DOLLAR);
    fprintf(file,'OBJLIST_FILE = %s\n',fileNameInfo.objListFile);

    fprintf(file,'TMWLIB = %s\n',getLinkObjStringForGroup(buildInfo,'TMWLIB'));

    excludeGroups={'TMWLIB'};
    userGroups={};
    fprintf(file,'THIRD_PARTY_LIBS = %s\n',getLinkObjStringForGroup(buildInfo,userGroups,excludeGroups));
    fprintf(file,'\n');
    fprintf(file,'#--------------------------------- Rules --------------------------------------\n');
    fprintf(file,'\n');
    fprintf(file,'MEX_FILE_NAME_WO_EXT = %s(MODEL)_%s(TARGET)\n',DOLLAR,DOLLAR);
    fprintf(file,'MEX_FILE_NAME = %s(MEX_FILE_NAME_WO_EXT).%s\n',DOLLAR,mexext);

    fprintf(file,'all : %s(MEX_FILE_NAME) \n',DOLLAR);
    fprintf(file,'\n');

    fprintf(file,'\n');
    fprintf(file,'%s(MEX_FILE_NAME) : %s(MAKEFILE) %s(OBJS)\n',DOLLAR,DOLLAR,DOLLAR);
    fprintf(file,'	@echo ### Linking ...\n');
    fprintf(file,'	%s(LD) %s(LDFLAGS) /OUT:%s(MEX_FILE_NAME) /map:"%s(MEX_FILE_NAME_WO_EXT).map" %s(TMWLIB) %s(THIRD_PARTY_LIBS) @%s(OBJLIST_FILE)\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR);

    fprintf(file,'     mt -outputresource:"%s(MEX_FILE_NAME);2" -manifest "%s(MEX_FILE_NAME).manifest"\n',DOLLAR,DOLLAR);
    fprintf(file,'	@echo ### Created %s@\n',DOLLAR);
    fprintf(file,'\n');

    fprintf(file,'.c.obj :\n');
    fprintf(file,'	@echo ### Compiling "%s<"\n',DOLLAR);
    fprintf(file,'	%s(CC) %s(CFLAGS) %s(INCLUDE_PATH) "%s<"\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR);
    fprintf(file,'\n');
    fprintf(file,'.cpp.obj :\n');
    fprintf(file,'	@echo ### Compiling "%s<"\n',DOLLAR);
    fprintf(file,'	%s(CC) %s(CFLAGS) %s(INCLUDE_PATH) "%s<"\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR);
    fprintf(file,'\n');
    for i=1:length(userSources)
        [pathStr,nameStr]=fileparts(userSources{i});
        objFileName=[nameStr,'.obj'];
        fprintf(file,'%s :	"%s"\n',objFileName,userSources{i});
        fprintf(file,'	@echo ### Compiling "%s"\n',userSources{i});
        fprintf(file,'	%s(CC) %s(CFLAGS) %s(INCLUDE_PATH) "%s"\n',DOLLAR,DOLLAR,DOLLAR,userSources{i});
    end

    fclose(file);

    function linkObjStr=getLinkObjStringForGroup(buildInfo,group,excludeGroups)


        if nargin<3
            excludeGroups={};
        end
        linkObjs=buildInfo.getLinkObjects(group,excludeGroups);
        linkObjStr='';
        for iL=1:numel(linkObjs)
            currLinkObjPath=linkObjs(iL).Path;
            currLinkObjPath=strrep(currLinkObjPath,'$(MATLAB_ROOT)',matlabroot);
            linkObjStr=[linkObjStr,'"',fullfile(currLinkObjPath,linkObjs(iL).Name),'" '];
        end

        function str=getCatString(incell)

            str=sprintf('%s ',incell{:});
            if~isempty(str)
                str(end)=[];
            end

            function str=getAltCatString(incell)

                for i=1:numel(incell)
                    [pathName,fileName,ext]=fileparts(incell{i});
                    pathName=cgxeprivate('cgxeAltPathName',pathName);
                    incell{i}=fullfile(pathName,[fileName,ext]);
                end
                str=getCatString(incell);
