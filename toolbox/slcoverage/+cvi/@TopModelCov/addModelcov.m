function addModelcov(this,modelH)




    modelcovId=get_param(modelH,'CoverageId');
    topModelcovId=get_param(this.topModelH,'CoverageId');
    cv('set',topModelcovId,'.refModelcovIds',unique([cv('get',topModelcovId,'.refModelcovIds'),modelcovId]));
    this.setLastReporting(modelH);
end
