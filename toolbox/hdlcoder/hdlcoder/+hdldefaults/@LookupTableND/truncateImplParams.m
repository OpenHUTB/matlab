function implInfo=truncateImplParams(~,slbh,implInfo)




    params={};
    if slbh<0
        return;
    end

    slobj=get_param(slbh,'Object');
    interpMethods=slobj.getPropAllowedValues('interpMethod');
    interp=get_param(slbh,'interpMethod');
    if any(strcmp(interp,interpMethods(1:2)))

        params{end+1}='precomputecoefficients';
        params{end+1}='areaoptimization';
    end

    if~isempty(params)
        implInfo.remove(params);
    end
end
