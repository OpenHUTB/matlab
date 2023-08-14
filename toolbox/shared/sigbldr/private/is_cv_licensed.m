function status=is_cv_licensed



    status=0;
    if(~license('test',SlCov.CoverageAPI.getLicenseName))
        return;
    end

    wState=warning;
    warning('off');
    try
        a=cv('get','default','slsfobj.isa');
        if~isempty(a)
            status=1;
        end
    catch isCvLicensedError %#ok<NASGU>

    end
    warning(wState);
