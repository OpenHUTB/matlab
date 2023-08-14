
function me=makeCause(meOld)




    me=MException(meOld.identifier,'%s',meOld.message);

    me=coderprivate.transferCauses(meOld,me);

