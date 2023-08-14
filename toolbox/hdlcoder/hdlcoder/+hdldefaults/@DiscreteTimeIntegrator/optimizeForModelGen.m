function optimize=optimizeForModelGen(~,~,hC)


    extReset=get_param(hC.SimulinkHandle,'ExternalReset');
    if strcmpi(extReset,'rising')||strcmpi(extReset,'falling')
        optimize=false;
    else
        optimize=true;
    end
end

