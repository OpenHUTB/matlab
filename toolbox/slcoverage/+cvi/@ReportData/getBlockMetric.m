function[data,objs]=getBlockMetric(this,sysEntry,metricObjsCnt,metricName)





    switch metricName
    case 'decision'
        [data,objs]=this.getDecisionBlock(sysEntry,metricObjsCnt);
    case 'condition'
        [data,objs]=this.getConditionBlock(sysEntry,metricObjsCnt);
    case 'mcdc'
        [data,objs]=this.getMcdcBlock(sysEntry,metricObjsCnt);
    case 'tableExec'
        [data,objs]=this.getTableExecBlock(sysEntry,metricObjsCnt);
    case 'sigrange'
        data=[];
        objs=[];
    end

