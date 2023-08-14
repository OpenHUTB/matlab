function result=runLinksAnalysis(model,commands,allowedFiles,traceLinkSupport)











    import coder.internal.clang.*;
    input=LinksInput(model);
    for file=string(allowedFiles(:))'
        input.AllowedFiles.add(file);
    end
    input.TraceLinkSupport=traceLinkSupport;
    analysis=LinksAnalysis(model);
    analysis.Input=input;
    Analysis.runAnalyses(commands,analysis);
    result=analysis.Output;
end


