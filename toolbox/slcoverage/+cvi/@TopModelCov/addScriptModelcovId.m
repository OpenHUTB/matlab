function addScriptModelcovId(this,modelH,modelcovId)




    topModelcovId=get_param(this.topModelH,'CoverageId');
    cv('set',topModelcovId,'.refModelcovIds',unique([cv('get',topModelcovId,'.refModelcovIds'),modelcovId]));
    cv('set',modelcovId,'.topModelcovId',topModelcovId);
end
