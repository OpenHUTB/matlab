function constructDataSegmentSections(CostResult,Chapter)



    import mlreportgen.report.*
    import mlreportgen.dom.*
    append(Chapter,PageBreak);
    section=Section('Title','Data Segment Table');
    dataSegmentReporter=designcostestimation.internal.reportutil.DataSegmentReporter;
    dataSegmentReporter.CostResult=CostResult;

    append(section,dataSegmentReporter);
    append(Chapter,section);
end


