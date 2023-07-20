function constructCostSections(CostResult,Chapter)







    import slreportgen.finder.*
    import mlreportgen.report.*
    import mlreportgen.dom.*
    s=Section('Title','Cost Breakdown Details');

    finder=SystemDiagramFinder(CostResult.Design);
    while hasNext(finder)
        diagramFinderResult=next(finder);
        section=Section(diagramFinderResult.Name);
        append(section,diagramFinderResult);
        costReporter=designcostestimation.internal.reportutil.CostReporter;
        costReporter.Diagram=diagramFinderResult.Object;
        costReporter.CostResult=CostResult;

        append(section,costReporter);
        append(s,section);
    end
    append(Chapter,s);
end


