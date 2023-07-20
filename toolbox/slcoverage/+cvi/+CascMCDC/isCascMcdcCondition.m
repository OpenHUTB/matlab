function ret=isCascMcdcCondition(id)





    ret=(cv('get',id,'.isa')==cv('get','default','condition.isa'))&&...
    (cv('get',id,'.cascMCDC.isCascMCDC')==1);
