function cmd=makehdlcmd(model,chip,codeFolder,constraint,userGuidanceFile,cpGuidanceFile,cpAnnotationFile,signalNamesMangling,generateModel,generateHDLCode,criticalPathEstimation)



    cmd=sprintf('makehdl(''%s/%s'', ''TargetDirectory'', ''%s'', ''Backannotation'', ''on'', ''GuidedRetiming'', ''on'', ''LatencyConstraint'', %f, ''OptimizationData'', ''%s'', ''CPGuidanceFile'', ''%s'', ''CPAnnotationFile'', ''%s'', ''SignalNamesMangling'', ''%s'', ''GenerateModel'', ''%s'', ''GenerateHDLCode'', ''%s'', ''CriticalPathEstimation'', ''%s'');',...
    model,chip,codeFolder,constraint,userGuidanceFile,cpGuidanceFile,cpAnnotationFile,signalNamesMangling,generateModel,generateHDLCode,criticalPathEstimation);

end

