function code_unix_make_file(buildInfo,fileNameInfo,modelName)



    import CGXE.Coder.*;

    fileName=fullfile(fileNameInfo.targetDirName,fileNameInfo.unixMakeFile);

    file=fopen(fileName,'Wt');
    if file<0
        throw(MException('Simulink:cgxe:FailedToCreateFile',fileName));
    end

    code_append_syslibs_to_objlist_file(fileNameInfo.objListFile,...
    fileNameInfo.targetDirName,buildInfo,modelName);
    DOLLAR='$';

    fprintf(file,'#--------------------------- Tool Specifications -------------------------\n');
    fprintf(file,'#\n');
    fprintf(file,'# Modify the following macros to reflect the tools you wish to use for\n');
    fprintf(file,'# compiling and linking your code.\n');
    fprintf(file,'#\n');

    codingMakeDebug=false;
    mexCFlag='-R2018a';
    if codingMakeDebug
        fprintf(file,'CC = %s/bin/mex %s -g\n',matlabroot,mexCFlag);
    else
        fprintf(file,'CC = %s/bin/mex %s\n',matlabroot,mexCFlag);
    end

    fprintf(file,'LD = %s(CC)\n',DOLLAR);
    fprintf(file,' \n');
    fprintf(file,'MODEL  = %s\n',modelName);
    fprintf(file,'TARGET = cgxe\n');



    moduleSrcs=getCatString(buildInfo.getSourceFiles(false,true,'MODULE_SRCS'));
    fprintf(file,'MODULE_SRCS 	= %s\n',moduleSrcs);
    modelSrc=getCatString(buildInfo.getSourceFiles(false,true,'MODEL_SRC'));
    fprintf(file,'MODEL_SRC	= %s\n',modelSrc);
    modelReg=getCatString(buildInfo.getSourceFiles(false,true,'MODEL_REG'));
    fprintf(file,'MODEL_REG    = %s\n',modelReg);

    fprintf(file,'MAKEFILE    = %s\n',fileNameInfo.unixMakeFile);

    fprintf(file,'MATLAB_ROOT	= %s\n',matlabroot);
    fprintf(file,'BUILDARGS   = \n');


    fprintf(file,'#------------------------------ Include/Lib Path ------------------------------\n');
    fprintf(file,' \n');
    fprintf(file,'\n');

    fprintf(file,' \n');
    userIncludeDirString='';
    userIncludeDirs=buildInfo.getIncludePaths(true,'USER_INCLUDES');
    if~isempty(userIncludeDirs)
        for i=1:length(userIncludeDirs)
            path=userIncludeDirs{i};
            userIncludeDirString=[userIncludeDirString,'-I"',path,'" '];%#ok<AGROW>
        end
    end
    fprintf(file,'USER_INCLUDES = %s\n',userIncludeDirString);

    mlslInclude=buildInfo.getIncludePaths(true,{'ML_INCLUDES','SL_INCLUDES'});
    fprintf(file,'MLSL_INCLUDES     = \\\n');
    numEle=numel(mlslInclude);
    for i=1:(numEle-1)
        fprintf(file,'    -I"%s" \\\n',mlslInclude{i});
    end
    fprintf(file,'    -I"%s"\n',mlslInclude{numEle});
    fprintf(file,'\n');
    thirdPartyIncludes=buildInfo.getIncludePaths(true,{},{'ML_INCLUDES','SL_INCLUDES','USER_INCLUDES'});
    thirdPartyIncludesString='';
    for i=1:length(thirdPartyIncludes)
        path=thirdPartyIncludes{i};
        thirdPartyIncludesString=[thirdPartyIncludesString,'-I"',path,'" '];%#ok<AGROW>
    end
    fprintf(file,'THIRD_PARTY_INCLUDES = %s\n',thirdPartyIncludesString);
    fprintf(file,'\n');
    fprintf(file,'INCLUDE_PATH = %s(MLSL_INCLUDES) %s(USER_INCLUDES) %s(THIRD_PARTY_INCLUDES)\n',DOLLAR,DOLLAR,DOLLAR);
    fprintf(file,' \n');

    fprintf(file,'#----------------- Compiler and Linker Options --------------------------------\n');
    fprintf(file,' \n');
    fprintf(file,'\n');
    fprintf(file,'CC_OPTS = %s %s\n',getCatString(buildInfo.getCompileFlags),getCatString(buildInfo.getDefines));

    fprintf(file,'CPP_REQ_DEFINES = -DMATLAB_MEX_FILE\n');
    fprintf(file,' \n');
    fprintf(file,'# Uncomment this line to move warning level to W4\n');
    fprintf(file,'# cflags = %s(cflags:W3=W4)\n',DOLLAR);
    fprintf(file,'CFLAGS = %s(CPP_REQ_DEFINES) %s(INCLUDE_PATH) CFLAGS="\\%s%sCFLAGS %s(CC_OPTS)"\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR);

    fprintf(file,' \n');
    fprintf(file,'LDFLAGS = %s\n',getCatString(buildInfo.getLinkFlags('LDFLAGS_CGXE')));
    fprintf(file,' \n');
    fprintf(file,'AUXLDFLAGS = %s\n',getCatString(buildInfo.getLinkFlags({},{'LDFLAGS_CGXE'})));


    fprintf(file,'#----------------------------- Source Files -----------------------------------\n');
    fprintf(file,' \n');
    userSources=buildInfo.getSourceFiles(true,true,'USER_SRCS');

    if(~isempty(userSources))
        fprintf(file,'USER_OBJS 	= \\\n');
        for i=1:length(userSources)
            [pathStr,nameStr]=fileparts(userSources{i});
            objStr=[nameStr,'.o'];
            fprintf(file,'		%s \\\n',objStr);
        end
    else
        fprintf(file,'USER_OBJS =\n');
    end
    fprintf(file,'\n');
    thirdPartyExcludeGroups={'MODULE_SRCS','MODEL_SRC','MODEL_REG','USER_SRCS'};

    thirdPartySources=buildInfo.getSourceFiles(false,true,{},thirdPartyExcludeGroups);


    thirdPartySourcePaths=buildInfo.getSourcePaths(true);

    fprintf(file,'AUX_SRCS = %s  \n',getCatString(thirdPartySources));
    fprintf(file,'\n');
    fprintf(file,'REQ_SRCS  = %s(MODEL_SRC) %s(MODEL_REG) %s(MODULE_SRCS) %s(AUX_SRCS) \n',DOLLAR,DOLLAR,DOLLAR,DOLLAR);
    fprintf(file,'\n');

    fprintf(file,'REQ_OBJS = %s(REQ_SRCS:.cpp=.o)\n',DOLLAR);
    fprintf(file,'REQ_OBJS2 = %s(REQ_OBJS:.c=.o)\n',DOLLAR);
    fprintf(file,'OBJS = %s(REQ_OBJS2) %s(USER_OBJS) %s(AUX_ABS_OBJS)\n',DOLLAR,DOLLAR,DOLLAR);
    fprintf(file,'OBJLIST_FILE = %s\n',fileNameInfo.objListFile);

    arch=lower(computer);
    fprintf(file,'TMWLIB = %s\n',getLinkObjStringForGroup(buildInfo,'TMWLIB'));
    fprintf(file,'PARLIB = %s\n',getLinkObjStringForGroup(buildInfo,'PARLIB'));

    fprintf(file,'  MAPCSF = %s/tools/%s/mapcsf\n',matlabroot,arch);
    fprintf(file,'   # RUN_MAPCSF_ON_UNIX is defined only if MAPCSF exists on this platform.\n');
    fprintf(file,'   ifneq (%s(wildcard %s(MAPCSF)),) # run MAPCSF if it exists on this platform\n',DOLLAR,DOLLAR);
    fprintf(file,'      RUN_MAPCSF_ON_UNIX =  %s/tools/%s/mapcsf %s@\n',matlabroot,arch,DOLLAR);
    fprintf(file,'   endif\n');
    fprintf(file,' \n');
    excludeGroups={'TMWLIB','PARLIB'};

    userGroups={};
    fprintf(file,'THIRD_PARTY_LIBS = %s\n',getLinkObjStringForGroup(buildInfo,userGroups,excludeGroups));
    fprintf(file,'\n');
    fprintf(file,'#--------------------------------- Rules --------------------------------------\n');
    fprintf(file,' \n');
    fprintf(file,'MEX_FILE_NAME = %s(MODEL)_%s(TARGET).%s\n',DOLLAR,DOLLAR,mexext);
    fprintf(file,' \n');
    fprintf(file,'%s(MEX_FILE_NAME): %s(MAKEFILE) %s(OBJS) %s(MEXLIB)\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR);
    fprintf(file,'	@echo ### Linking ...\n');
    fprintf(file,'	%s(CC) -silent LDFLAGS="\\%s%sLDFLAGS %s(LDFLAGS) %s(AUXLDFLAGS)" -output %s(MEX_FILE_NAME) @%s(OBJLIST_FILE) %s(OBJS) %s(TMWLIB) %s(PARLIB) %s(THIRD_PARTY_LIBS) \n',DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR);
    fprintf(file,'	%s(RUN_MAPCSF_ON_UNIX)\n',DOLLAR);
    fprintf(file,'\n');
    fprintf(file,'%%.o :	%%.c\n');
    fprintf(file,'	%s(CC) -c %s(CFLAGS) %s<\n',DOLLAR,DOLLAR,DOLLAR);
    fprintf(file,'\n');
    fprintf(file,'%%.o :	%%.cpp\n');
    fprintf(file,'	%s(CC) -c %s(CFLAGS) %s<\n',DOLLAR,DOLLAR,DOLLAR);
    fprintf(file,'\n');

    thirdPartySourceFiles=buildInfo.getSourceFiles(true,true,{},thirdPartyExcludeGroups);

    for i=1:length(thirdPartySourceFiles)
        fullSrcName=CGXE.Utils.tokenizeFileFromModel(thirdPartySourceFiles{i},modelName,thirdPartySourcePaths);
        objFileName=code_unix_change_ext(thirdPartySources{i},'o');
        fprintf(file,'%s :	%s\n',objFileName,escapePathStr(fullSrcName));
        fprintf(file,'	%s(CC) -c %s(CFLAGS) %s\n',DOLLAR,DOLLAR,escapePathStr(fullSrcName));
    end

    for i=1:numel(thirdPartySourceFiles)
        [fullSrcName,srcFileName]=CGXE.Utils.tokenizeFileFromModel(thirdPartySourceFiles{i},modelName,thirdPartySourcePaths);
        if~isempty(fullSrcName)
            pathStr=fileparts(fullSrcName);
        end
        fprintf(file,'%%.o : %s%s%%.c\n',pathStr,filesep);
        fprintf(file,'	%s(CC) -c %s(CFLAGS) %s<\n',DOLLAR,DOLLAR,DOLLAR);
    end

    for i=1:length(userSources)
        objFileName=code_unix_change_ext(userSources{i},'o');
        fprintf(file,'%s :	%s\n',objFileName,escapePathStr(userSources{i}));
        fprintf(file,'	%s(CC) -c %s(CFLAGS) %s\n',DOLLAR,DOLLAR,escapePathStr(userSources{i}));
    end
    fclose(file);

    function result=code_unix_change_ext(filename,ext)

        [path_str,name_str]=fileparts(filename);
        result=[name_str,'.',ext];

        function linkObjStr=getLinkObjStringForGroup(buildInfo,group,excludeGroups)


            if nargin<3
                excludeGroups={};
            end
            linkObjs=buildInfo.getLinkObjects(group,excludeGroups);
            linkObjStr='';
            for iL=1:numel(linkObjs)
                currLinkObjPath=linkObjs(iL).Path;
                currLinkObjPath=escapePathStr(strrep(currLinkObjPath,'$(MATLAB_ROOT)',matlabroot));
                if isempty(group)

                    linkObjStr=[linkObjStr,currLinkObjPath,filesep,linkObjs(iL).Name,' '];
                else
                    linkObjStr=[linkObjStr,'-L',currLinkObjPath,' -l',linkObjs(iL).Name,' '];
                end
            end


            function str=getCatString(incell)

                str=sprintf('%s ',incell{:});
                if~isempty(str)
                    str(end)=[];
                end


                function escStr=escapePathStr(inpath)


                    escStr=regexprep(strtrim(inpath),' ','\\ ');
