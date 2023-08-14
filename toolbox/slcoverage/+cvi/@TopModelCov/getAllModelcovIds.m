function allIds=getAllModelcovIds(this)




    topModelcovId=get_param(this.topModelH,'CoverageId');
    allIds=cv('get',topModelcovId,'.refModelcovIds');
end
