

function str=rtwdemolicensecheck(product)

    str='';

    switch product
    case 'sfsfc'
        if~lCheckoutLicense('Stateflow')||~lCheckoutLicense('Stateflow_Coder')
            str=['You must install Stateflow to run this example.'];
        end
    case 'sp'
        if~lCheckoutLicense('Signal_Blocks')
            str=['You must install DSP System Toolbox to view this ',...
            'example.'];
        end
    otherwise
        error(['Unknown case: ',product])
    end

    function licenseFound=lCheckoutLicense(featureName)

        licenseFound=(builtin('_license_checkout',featureName,'quiet')...
        ==0);

