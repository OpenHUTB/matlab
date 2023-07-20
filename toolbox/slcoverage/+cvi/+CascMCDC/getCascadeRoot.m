function cascRoot=getCascadeRoot(memberBlockCvId)






    cascRoot=[];
    try
        condMetricEnum=cvi.MetricRegistry.getEnum('condition');
        conditions=cv('MetricGet',memberBlockCvId,condMetricEnum,'.baseObjs');

        if~isempty(conditions)
            [isCascMCDC,linkedSlsfobj]=cv('get',conditions(1),...
            '.cascMCDC.isCascMCDC','.cascMCDC.linkedSlsfobj');
            if(isCascMCDC==0)&&(linkedSlsfobj~=0)
                cascRoot=linkedSlsfobj;
            end
        end
    catch
        cascRoot=[];
    end
