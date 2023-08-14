function[sids,csVals]=getIncrementalSubsystemChecksums(mdlName)

    sids={};
    csVals={};



    fileToLoad=fullfile(RTW.getBuildDir(mdlName).BuildDirectory,'incsubsys.mat');

    if exist(fileToLoad,'file')
        load(fileToLoad);
        sids=incSubsysInfo.SIDs;
        csVals=incSubsysInfo.checksums;
    end
end
