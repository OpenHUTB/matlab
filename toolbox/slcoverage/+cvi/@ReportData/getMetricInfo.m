function cvstruct=getMetricInfo(this,cvstruct,metricObjs,metricName,options)




    textDetails=2;
    switch metricName
    case 'decision'
        decisionData=this.metricData.decision;
        cvstruct.decisions=this.getDecisionInfo(metricName,decisionData,metricObjs,textDetails);
    case 'condition'
        cvstruct=this.getConditionInfo(cvstruct,metricObjs,textDetails);
    case 'mcdc'
        cvstruct=this.getMcdcInfo(cvstruct,metricObjs,textDetails,options);
    case 'tableExec'
        cvstruct=this.getTableExecInfo(cvstruct,metricObjs,options);

    end
