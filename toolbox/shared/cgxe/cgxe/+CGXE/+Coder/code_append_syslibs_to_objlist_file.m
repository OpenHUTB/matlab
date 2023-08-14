function libList=code_append_syslibs_to_objlist_file(objFile,targetDirName,buildInfo,modelName)



    cfg=getActiveConfigSet(modelName);
    [syslibs,syslibpaths]=buildInfo.getSysLibInfo;
    forMex=true;
    delimiter=newline;
    lcc64Default=true;


    if strcmpi(get_param(modelName,'SimTargetLang'),'C++');

        mxcc=mex.getCompilerConfigurations('C++','selected');
        lMexCompilerKey=cgxeprivate('hCreateCompStr',mxcc);
    else
        lDefaultCompInfo=coder.internal.DefaultCompInfo.createDefaultCompInfo;
        lMexCompilerKey=lDefaultCompInfo.DefaultMexCompilerKey;
    end

    linkFlags=strtrim(coder.make.Builder.generateSystemLibraryLinkFlag...
    (cfg,syslibs,syslibpaths,forMex,delimiter,lcc64Default,lMexCompilerKey));
    matlabrootEscaped=escapePathStr(matlabroot);
    linkFlags=strrep(linkFlags,'$(MATLAB_ROOT)',matlabrootEscaped);
    fileName=fullfile(targetDirName,objFile);
    file=fopen(fileName,'At');
    if file<3
        throw(MException('Simulink:cgxe:FailedToCreateFile',fileName));
    end
    cl=onCleanup(@()fclose(file));
    fprintf(file,'%s\n',linkFlags);
    libList{1}=linkFlags;

    function escStr=escapePathStr(inpath)


        escStr=RTW.transformPaths(inpath,'ignoreErrors',false,'pathType','alternate','mapUNCPaths',false);
