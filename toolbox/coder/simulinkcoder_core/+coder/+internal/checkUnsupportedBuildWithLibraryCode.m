function checkUnsupportedBuildWithLibraryCode(buildDir,lBuildHookHandles,...
    lNeedInstrBuild)









    if lNeedInstrBuild&&~coder.make.internal.featureOn('SilPwsReusableLibs')
        isBullseyeOrLDRA=false;
        for i=1:length(lBuildHookHandles)
            if isa(lBuildHookHandles{i},'coder.coverage.LDRA')||...
                isa(lBuildHookHandles{i},'coder.coverage.Bullseye')
                isBullseyeOrLDRA=true;
            end
        end

        if isBullseyeOrLDRA&&~isempty(coder.internal.getRLSPaths(buildDir))
            DAStudio.error('Simulink:librarycodegen:InstrumentedBuildUsingLibraryCode');
        end
    end
