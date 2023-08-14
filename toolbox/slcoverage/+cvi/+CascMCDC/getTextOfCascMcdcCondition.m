function str=getTextOfCascMcdcCondition(condId)




    [slsfobj,linkedSlsfobj,linkedInPortIdx]=cv('get',condId,'.slsfobj',...
    '.cascMCDC.linkedSlsfobj',...
    '.cascMCDC.linkedInPortIdx');

    mcdcMetricEnum=cvi.MetricRegistry.getEnum('mcdc');
    mcdcBaseObjId=cv('MetricGet',slsfobj,mcdcMetricEnum,'.baseObjs');
    cascMcdcConditions=cv('get',mcdcBaseObjId,'.conditions');
    condNumber=find(cascMcdcConditions==condId);


    blockH=cv('get',linkedSlsfobj,'.handle');


    inNumber=linkedInPortIdx+1;

    str=cvi.CascMCDC.getConditionDescrString(condNumber,blockH,inNumber);%#ok<FNDSB>
