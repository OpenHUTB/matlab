function lIsTMFBased=getIsTMFBased(buildOpts)




    if~buildOpts.MakefileBasedBuild
        lIsTMFBased=false;
    else
        [~,lTMFProperties]=coder.make.internal.resolveToolchainOrTMF(buildOpts.BuildMethod);
        lIsTMFBased=~isempty(lTMFProperties);
    end
