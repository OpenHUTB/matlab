function composeSpec=getNetworkSpec(testcomp)



    composeSpec=struct([]);

    options=testcomp.activeSettings;
    if Sldv.utils.isPathBasedTestGeneration(options)
        composeSpec=testcomp.pathCompositionSpec;
    end
end
