function saveCachedGlobalIOData(globalIOs,fullChecksum,newGlobalIOChecksum,settingsChecksum)






    [success,~,~]=loadCachedGlobalIOData(settingsChecksum,fullChecksum);
    if success
        return;
    end
    projRootDir=cgxeprivate('get_cgxe_proj_root');
    globalIOMATPath=fullfile(projRootDir,'slprj','_slcc',settingsChecksum);
    globalIOMATFile=fullfile(projRootDir,'slprj','_slcc',settingsChecksum,[settingsChecksum,'_globalIO.mat']);


    try
        if~CGXE.Utils.isFolderWritable(projRootDir)

            return
        end
        if~isfolder(globalIOMATPath)
            mkdir(globalIOMATPath);
        end
        save(globalIOMATFile,'globalIOs','fullChecksum','newGlobalIOChecksum');

    catch ME
        warning(ME.message);
    end

end

