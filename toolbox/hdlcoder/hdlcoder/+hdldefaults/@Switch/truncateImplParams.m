function implInfo=truncateImplParams(~,slbh,implInfo)

    params={};
    if slbh<0
        return;
    end

    selectedCriteria=get_param(slbh,'Criteria');
    swObj=get_param(slbh,'Object');
    criteriaValues=swObj.getPropAllowedValues('Criteria');


    noNFPOptCriteria={
    criteriaValues{3}...
    };%#ok<CCAT1>


    if strcmp(selectedCriteria,noNFPOptCriteria)
        params={'latencystrategy'};
    end

    if~isempty(params)
        implInfo.remove(params);
    end

end

