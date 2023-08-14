function constructOperatorCountSections(CostResult,Chapter)






    import mlreportgen.report.*
    import mlreportgen.dom.*
    append(Chapter,PageBreak);
    section=Section('Title','Operator Count');

    designcostestimation.internal.reportutil.constructHighLevelStats(CostResult,section);

    designcostestimation.internal.reportutil.constructCostSections(CostResult,section);

    append(Chapter,section);
end


