



function mode=getMcdcMode(h)

    mode=SlCov.McdcMode.UniqueCause;

    if SlCov.isMaskingMcdcCovFeatureOn
        modelcovId=get_param(h,'CoverageId');
        activeTestId=cv('get',modelcovId,'.activeTest');
        if(activeTestId>0)
            mode=SlCov.McdcMode(cv('get',activeTestId,'.mcdcMode'));
        else
            mode=SlCov.McdcMode(get_param(h,'CovMcdcMode'));
        end
    end

    mode=mode.uint16;