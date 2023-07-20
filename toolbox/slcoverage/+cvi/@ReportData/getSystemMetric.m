function[data,objs]=getSystemMetric(this,sysEntry,metricObjsCnt,metricName)





    switch metricName
    case 'decision'
        [data,objs]=this.getDecisionSystem(sysEntry,metricObjsCnt);
    case 'condition'
        [data,objs]=this.getConditionSystem(sysEntry,metricObjsCnt);
    case 'mcdc'
        [data,objs]=this.getMcdcSystem(sysEntry,metricObjsCnt);
    case 'tableExec'
        [data,objs]=this.getTableExecSystem(sysEntry,metricObjsCnt);
    case 'sigrange'
        data=[];
        objs=[];
    end

