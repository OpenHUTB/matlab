

function[ranges,expressions,coverageInfo,errorMessage,messages]=fpRunSimulation(...
    data,entryPoint,testFile,synthetic,mexTestFile,logIO,preRunChecksum,isCheckForIssues,resetCache)

    try
        [ranges,expressions,coverageInfo,errorMessage,messages]=...
        coderprivate.Float2FixedManager.instance.runSimulation(data,entryPoint,testFile,synthetic,mexTestFile,logIO);

        manager=coder.internal.F2FGuiCallbackManager.getInstance();

        if~isCheckForIssues
            targetFieldName='SimulationOutput';
        else
            targetFieldName='CheckForIssuesOutput';
        end

        if resetCache
            manager.(targetFieldName)={};
        end

        manager.(targetFieldName){end+1}={ranges,expressions,coverageInfo,errorMessage,messages};
        manager.Checksum=preRunChecksum;
    catch ex
        throwAsCaller(ex);
    end
end
