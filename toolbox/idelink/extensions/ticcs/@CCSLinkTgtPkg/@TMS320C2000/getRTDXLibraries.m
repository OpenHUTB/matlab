function list=getRTDXLibraries(h,tgtinfo,mdlinfo)





    list={};
    if mdlinfo.RTDXIntNeeded
        list{1}='$(BIOS_INSTALL_DIR)\packages\ti\rtdx\lib\c2000\rtdxx.lib';
    end