
function[sysSummary,blkSummary]=testobjective_summary(testCnt,metricName,options)



    if testCnt==1
        totalCol=1;
    elseif options.cumulativeReport
        totalCol=3;
    else
        totalCol=testCnt+1;
    end
    txtObjectiveOutcomes=getString(message('Slvnv:simcoverage:cvhtml:ObjectiveOutcomes'));
    metricSummAbbrev=cvi.MetricRegistry.getLongMetricTxt(metricName,options);

    [sysSummary,blkSummary]=cvi.ReportScript.decision_summary_script(metricName,totalCol,txtObjectiveOutcomes,metricSummAbbrev);



