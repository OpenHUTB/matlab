function fluxCst=spsDrivesVectorControllerPmsmFluxConstantCbak(block,nb_p,fluxConstant,voltageConstant,torqueConstant)

    choice=get_param(block,'machineConstant');
    nbPhases=get_param(block,'nb_ph');

    polePairs=nb_p;

    switch choice

    case 'Flux linkage established by magnets (V.s)'


        fluxCst=fluxConstant;

    case 'Voltage Constant (V_peak L-L / krpm)'


        voltageCst=voltageConstant;

        switch nbPhases
        case '5'
            fluxCst=voltageCst/(100*pi*polePairs*(sqrt(5-sqrt(5))*sqrt(2)/6));
        case '3'
            fluxCst=sqrt(3)*voltageCst/(100*pi*polePairs);
        end

    case 'Torque Constant (N.m / A_peak)'


        torqueCst=torqueConstant;

        switch nbPhases
        case '5'
            fluxCst=2*torqueCst/(5*polePairs);
        case '3'
            fluxCst=2*torqueCst/(3*polePairs);
        end
    end
