function ok=checkForToolbox(toolboxVerName,doCheckout)

























    if~exist('doCheckout','var')
        doCheckout=false;
    end

    switch toolboxVerName
    case 'matlab'

        ok=true;
        return;
    case 'stats'
        toolboxLicenseName='Statistics_Toolbox';
    case 'optim'
        toolboxLicenseName='Optimization_Toolbox';
    case 'globaloptim'
        toolboxLicenseName='GADS_Toolbox';
    case 'compiler'
        toolboxLicenseName='Compiler';
    case 'parallel'
        toolboxLicenseName='Distrib_Computing_Toolbox';
    otherwise
        ok=false;
        return
    end

    if~license('test',toolboxLicenseName)||isempty(ver(toolboxVerName))

        ok=false;
    elseif doCheckout

        ok=license('checkout',toolboxLicenseName);
    else

        ok=true;
    end
