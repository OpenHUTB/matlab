function hideCascMCDCConditions(modelcovId)









    mcdcIsa=cv('get','default','mcdc.isa');
    mcdcObjs=cv('find','all','.isa',mcdcIsa);
    mcdcObjs=cv('find',mcdcObjs,'.modelcov',modelcovId);
    cascMCDCList=cv('find',mcdcObjs,'.cascMCDC.isCascMCDC',1);
    for i=1:length(cascMCDCList)
        cascMCDC=cascMCDCList(i);
        removeFallbackMcdc(cascMCDC);

        cascConditions=cv('get',cascMCDC,'.conditions');
        if areCascConditions(cascConditions)






            removeCascCondsFromBaseobj(cascMCDC,cascConditions);
            linkBackCascConds(cascMCDC,cascConditions);
        end
    end
end

function isCasc=areCascConditions(conditions)






    isCasc=false;

    for i=1:length(conditions)
        if~cv('get',conditions(i),'.cascMCDC.isCascMCDC')
            return
        end
    end
    isCasc=true;
end

function removeCascCondsFromBaseobj(cascMCDC,cascConditions)



    condMetricEnum=cvi.MetricRegistry.getEnum('condition');
    slsfobj=cv('get',cascMCDC,'.slsfobj');
    [metric,baseObjs_all]=cv('MetricGet',slsfobj,condMetricEnum,'.id','.baseObjs');
    baseObjs_noCasc=setdiff(baseObjs_all,cascConditions,'stable');

    if(length(baseObjs_all)~=length(baseObjs_noCasc))
        cv('set',metric,'.baseObjs',baseObjs_noCasc);
    end
end


function condition=findCondition(slsfobj,inPortIdx)


    condMetricEnum=cvi.MetricRegistry.getEnum('condition');
    baseObjs=cv('MetricGet',slsfobj,condMetricEnum,'.baseObjs');
    condition=baseObjs(inPortIdx+1);
end

function linkBackCascConds(cascMCDC,cascConditions)




    condMetricEnum=cvi.MetricRegistry.getEnum('condition');
    [cascMemberBlocks,rootBlockCvId]=cv('get',cascMCDC,'.cascMCDC.memberBlocks','.slsfobj');
    conditions=cv('MetricGet',cascMemberBlocks,condMetricEnum,'.baseObjs');
    conditions=conditions(:);
    cv('set',conditions,'.cascMCDC.isCascMCDC',0);
    cv('set',conditions,'.cascMCDC.linkedSlsfobj',rootBlockCvId);
    cv('set',conditions,'.cascMCDC.linkedInPortIdx',-1);


    for i=1:length(cascConditions)
        curCond=cascConditions(i);
        if cv('get',curCond,'.cascMCDC.isCascMCDC')
            [linkedSlsfobj,linkedInPortIdx]=cv('get',curCond,...
            '.cascMCDC.linkedSlsfobj','.cascMCDC.linkedInPortIdx');
            linkedCond=findCondition(linkedSlsfobj,linkedInPortIdx);
            cv('set',linkedCond,'.cascMCDC.linkedInPortIdx',i-1);
        end
    end
end

function removeFallbackMcdc(cascMCDC)




    mcdcMetricEnum=cvi.MetricRegistry.getEnum('mcdc');
    memberBlockList=cv('get',cascMCDC,'.cascMCDC.memberBlocks');

    for memberBlock=memberBlockList
        mcdcMetricId=cv('MetricGet',memberBlock,mcdcMetricEnum,'.id');
        mcdcBaseObjs=cv('get',mcdcMetricId,'.baseObjs');
        mcdcObjsToDelete=cv('find',mcdcBaseObjs,'.cascMCDC.isCascMCDC',0);
        deleteMcdcEntry(memberBlock,mcdcMetricId,mcdcObjsToDelete)
    end
end

function deleteMcdcEntry(slsfobj,mcdcmetric,mcdcentry)



    descToDelete=cv('get',mcdcentry,'.descriptor');
    cv('delete',descToDelete);


    cv('delete',mcdcentry);


    baseObjs=cv('get',mcdcmetric,'.baseObjs');
    if(length(baseObjs)>length(mcdcentry))

        baseObjs=setdiff(baseObjs,mcdcentry,'stable');
        cv('set',mcdcmetric,'.baseObjs',baseObjs);
    else


        cv('delete',mcdcmetric);
        metricList=cv('get',slsfobj,'.metrics');
        metricList=setdiff(metricList,mcdcmetric,'stable');
        cv('set',slsfobj,'.metrics',metricList);


        metricFlags=cv('get',slsfobj,'.metricFlags');
        mcdcMetricEnum=cvi.MetricRegistry.getEnum('mcdc');
        mcdcOffMask=bitcmp(bitshift(uint32(1),mcdcMetricEnum));
        metricFlags=double(bitand(metricFlags,mcdcOffMask));
        cv('set',slsfobj,'.metricFlags',metricFlags);
    end
end
