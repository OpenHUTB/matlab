function[success,globalIOs,newGlobalIOChecksum]=loadCachedGlobalIOData(settingsChecksum,fullChecksum)




    success=false;
    newGlobalIOChecksum=[];
    globalIOs=[];

    projRootDir=cgxeprivate('get_cgxe_proj_root');
    globalIOMATFile=fullfile(projRootDir,'slprj','_slcc',settingsChecksum,[settingsChecksum,'_globalIO.mat']);
    if isfile(globalIOMATFile)
        savedGlobalIOInfo=load(globalIOMATFile);
        if isequal(fullChecksum,savedGlobalIOInfo.fullChecksum)
            globalIOs=savedGlobalIOInfo.globalIOs;
            newGlobalIOChecksum=savedGlobalIOInfo.newGlobalIOChecksum;
            success=true;
        end
    end
end

