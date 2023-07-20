function buildCoderAssumptionsForSDP(generateCodeOnly,platformType,buildFolder)




    if~generateCodeOnly&&platformType==coder.internal.rte.PlatformType.Function&&...
        coder.make.internal.featureOn('BuildCoderAssumptionsForSDP')
        buildStandaloneCoderAssumptions(buildFolder);
    end
end