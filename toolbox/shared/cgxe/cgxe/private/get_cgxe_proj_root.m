function[rootDir,isCustomRootDir]=get_cgxe_proj_root(varargin)

    fileGenCfg=Simulink.fileGenControl('getConfig');
    rootDir=fileGenCfg.CacheFolder;
    isCustomRootDir=true;