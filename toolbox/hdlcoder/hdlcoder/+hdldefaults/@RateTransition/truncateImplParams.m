function implInfo=truncateImplParams(~,slbh,implInfo)

    params={};
    if slbh<0
        return;
    end

    dintegrity=get_param(slbh,'Integrity');

    if strcmp(dintegrity,'on')


        params{end+1}='asyncrtaswire';
    end

    if~isempty(params)
        implInfo.remove(params);
    end


