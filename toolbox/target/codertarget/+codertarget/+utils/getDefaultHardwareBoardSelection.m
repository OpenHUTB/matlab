function str=getDefaultHardwareBoardSelection(hCS)




    stf=get_param(hCS,'SystemTargetFile');
    areCoderLicensed=license('test','Real-Time_Workshop')&&...
    license('test','RTW_Embedded_Coder')&&...
    license('test','MATLAB_Coder');

    if~areCoderLicensed||isequal(stf,'ert.tlc')||...
        isequal(stf,'realtime.tlc')||isequal(stf,'autosar.tlc')
        str=DAStudio.message('codertarget:build:DefaultHardwareBoardNameNone');
    else
        str=DAStudio.message('codertarget:build:DefaultHardwareBoardNameDeterminebySTF');
    end
end
