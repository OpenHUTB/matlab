

function[ranges,expressions,messages,errorMessage,bbaResult]=fpComputeStaticRanges(data,entryPoint,preRunChecksum)
    [ranges,expressions,messages,errorMessage,bbaResult]=coderprivate.Float2FixedManager.instance.computeDerivedRanges(data,entryPoint);

    manager=coder.internal.F2FGuiCallbackManager.getInstance();
    manager.DerivedRangeAnalysisOutput={ranges,expressions,messages,errorMessage,bbaResult};
    manager.Checksum=preRunChecksum;
end
