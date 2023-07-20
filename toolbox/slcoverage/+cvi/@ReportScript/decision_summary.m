function[sysSummary,blkSummary]=decision_summary(testCnt,options)








    if testCnt==1
        totalCol=1;
    elseif options.cumulativeReport
        totalCol=3;
    else
        totalCol=testCnt+1;
    end
    txtDecision=getString(message('Slvnv:simcoverage:decisionMetric'));
    txtDecisionOutcomes=getString(message('Slvnv:simcoverage:cvhtml:DecisionOutcomes'));
    metricSummAbbrev=txtDecision;
    [sysSummary,blkSummary]=cvi.ReportScript.decision_summary_script('decision',totalCol,txtDecisionOutcomes,metricSummAbbrev);
