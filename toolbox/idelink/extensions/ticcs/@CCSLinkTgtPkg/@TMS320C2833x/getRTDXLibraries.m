function list=getRTDXLibraries(h,tgtinfo,mdlinfo)




    list={};
    if mdlinfo.RTDXIntNeeded
        if(~isempty(strfind(tgtinfo.chipInfo.deviceID,'283')))
            list{1}='$(BIOS_INSTALL_DIR)\packages\ti\rtdx\lib\c2000\rtdxfp.lib';
        else
            list{1}='$(BIOS_INSTALL_DIR)\packages\ti\rtdx\lib\c2000\rtdxx.lib';
        end
    end
