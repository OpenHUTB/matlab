function unpackProtectedModelSimCommon(fullName,...
    opts,...
    topMdl,...
    relationship,simYear,...
    relationshipUtils,simSharedUtilsYear,...
    isSimForRTWBuild)




    import Simulink.ModelReference.ProtectedModel.*;







    if(~slInternal('isProtectedModelFromThisSimulinkVersion',fullName))
        protectedModelSimulinkVersion=slInternal('getProtectedModelVersion',fullName);
        if isSimForRTWBuild







            if simulink_version(protectedModelSimulinkVersion)<simulink_version('R2020b')
                locDoUnpack(fullName,opts,relationship,simYear);
            end
        else

            DAStudio.error('Simulink:protectedModel:protectedModelSimulinkVersionMismatch',opts.modelName,protectedModelSimulinkVersion);
        end
    else

        [rootSimDirBase,rootSimDir,buildDirs]=locDoUnpack(fullName,opts,relationship,simYear);
        extractSharedUtils(fullName,rootSimDir,'',relationshipUtils,simSharedUtilsYear,...
        topMdl,rootSimDirBase,buildDirs);
    end
end

function[rootSimDirBase,rootSimDir,buildDirs]=locDoUnpack(fullName,opts,relationship,simYear)
    import Simulink.ModelReference.ProtectedModel.*;
    rootSimDirBase=getSimBuildDir();


    buildDirs=RTW.getBuildDir(opts.modelName);
    rootSimDir=fullfile(rootSimDirBase,buildDirs.ModelRefRelativeRootSimDir);


    dstDir=rootSimDirBase;
    writeRelationship(fullName,dstDir,relationship,simYear);


    for i=1:length(opts.subModels)
        addCleanupListenerForAccelSim(fullfile(rootSimDir,opts.subModels{i}));
    end
end


