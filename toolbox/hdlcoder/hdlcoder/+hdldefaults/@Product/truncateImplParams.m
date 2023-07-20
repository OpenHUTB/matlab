function implInfo=truncateImplParams(~,slbh,implInfo)

    params={};
    if slbh<0
        return;
    end

    inputs=get_param(slbh,'Inputs');

    if strcmp(inputs,'/')||strcmp(inputs,'//')





        return
    end

    if~isnan(str2double(inputs))...
        ||~contains(inputs,'/')

        params{end+1}='divisionalgorithm';
    elseif length(strfind(inputs,'*'))<2

        params{end+1}='mantissamultiplystrategy';
    else


    end

    if~isempty(params)
        implInfo.remove(params);
    end



