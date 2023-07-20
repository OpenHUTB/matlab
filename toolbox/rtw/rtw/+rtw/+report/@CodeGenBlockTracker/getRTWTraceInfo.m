function traceInfo=getRTWTraceInfo(obj,buildDir)



    model=obj.ModelName;
    if~isempty(obj.SourceSubsystem)
        model=Simulink.ID.getModel(obj.SourceSubsystem);
    end
    traceInfo=RTW.TraceInfo(model,buildDir);
end
