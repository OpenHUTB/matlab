function constructHighLevelStats(CostResult,ParentSection)





    import slreportgen.finder.*
    import mlreportgen.report.*
    import mlreportgen.dom.*
    section=Section('Title','High Level Statistics');
    append(section,['Total Cost of Design is ',num2str(CostResult.TotalCost)]);
    StatsReporter=designcostestimation.internal.reportutil.HighLevelStatsReporter;
    StatsReporter.CostResult=CostResult;
    append(section,StatsReporter);
    append(section,PageBreak);
    append(ParentSection,section);
end
