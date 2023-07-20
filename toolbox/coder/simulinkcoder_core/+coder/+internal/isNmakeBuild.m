function usingNmake=isNmakeBuild(lTMFProperties,lToolchainBuildArtifact)






    usingNmake=false;
    if~isempty(lTMFProperties)
        makeCmd=getMAKECMD(lTMFProperties);
        if~isempty(makeCmd)

            usingNmake=regexp(makeCmd,'.*?nmake$');
        end
    else
        usingNmake=contains(lToolchainBuildArtifact,'nmake');
    end
