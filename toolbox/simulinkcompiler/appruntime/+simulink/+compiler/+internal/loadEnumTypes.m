

function loadEnumTypes(model)



    product="Simulink_Compiler";
    [status,msg]=builtin('license','checkout',product);
    if~status
        product=extractBetween(msg,'Cannot find a license for ','.');
        if~isempty(product)
            error(message('simulinkcompiler:build:LicenseCheckoutError',product{1}));
        end
        error(msg);
    end

    model=convertStringsToChars(model);
    if~Simulink.isRaccelDeployed
        return
    end

    mi=Simulink.RapidAccelerator.getStandaloneModelInterface(model);
    if isempty(mi.startTime)
        mi.startTime=clock;
    end
    mi.initializeForDeployment();
    mi.loadEnumDefinitions();
end
