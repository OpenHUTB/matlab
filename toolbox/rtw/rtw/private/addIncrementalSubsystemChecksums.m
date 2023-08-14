function addIncrementalSubsystemChecksums(mdlName,sids,checksums)



    fileToSave=fullfile(RTW.getBuildDir(mdlName).BuildDirectory,'incsubsys.mat');

    incSubsysInfo.SIDs=sids;
    incSubsysInfo.checksums=checksums;
    save(fileToSave,'incSubsysInfo');
end
