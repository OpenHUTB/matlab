function result=runTraceAnalysis(model,commands)








    import coder.internal.clang.*;
    analysis=TraceAnalysis(model);
    Analysis.runAnalyses(commands,analysis);
    result=analysis.Output;
end


