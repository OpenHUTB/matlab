function summaryTable=utilCreateSummaryTable(table,tableName)


    rh1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Performance');
    rh2=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Accuracy');
    rh3=DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimulationTimeHeading');
    rh={rh1,rh2,rh3};

    ch1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:TimeBefore');
    ch2=DAStudio.message('SimulinkPerformanceAdvisor:advisor:TimeAfter');
    ch3=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Improvement');
    ch={ch1,ch2,ch3};

    table{1,1}=ModelAdvisor.Text('');
    table{1,2}=ModelAdvisor.Text('');

    summaryTable=utilDrawReportTable(table,tableName,rh,ch);
end