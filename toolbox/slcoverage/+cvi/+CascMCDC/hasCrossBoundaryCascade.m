function ret=hasCrossBoundaryCascade(subsysCvId)






    ret=false;

    if ischar(subsysCvId)||isempty(subsysCvId)||(subsysCvId==0)
        return
    end

    metricEnumVal=cvi.MetricRegistry.getEnum('mcdc');
    allSlsfObjsInSys=cv('DecendentsOf',subsysCvId);
    mcdcIds=cv('MetricGet',allSlsfObjsInSys,metricEnumVal,'.baseObjs');
    mcdcIds(mcdcIds==0)=[];
    cascMcdcIds=cv('find',mcdcIds,'.cascMCDC.isCascMCDC',1);

    for i=1:length(cascMcdcIds)
        cascMemberBlockIds=cv('get',cascMcdcIds(i),'.cascMCDC.memberBlocks');
        if~all(ismember(cascMemberBlockIds,allSlsfObjsInSys))
            ret=true;
            break;
        end
    end

