function fluxCst=spsDrivesCurrentControllerBrushlessDcFluxConstantCbak(block,nb_p,fluxConstant,voltageConstant,torqueConstant,flat)

    choice=get_param(block,'machineConstant');

    switch choice
    case{'Voltage Constant (V_peak L-L / krpm)','Torque Constant (N.m / A_peak)'}

        polePairs=nb_p;

        flatArea=flat;
    end

    switch choice
    case 'Flux linkage established by magnets (V.s)'

        fluxCst=fluxConstant;

    case 'Voltage Constant (V_peak L-L / krpm)'

        voltageCst=voltageConstant;
        fluxCst=voltageCst/(polePairs*sqrt(3)*(1000/30*pi)/(cos(min(flatArea,60)*pi/360)));

    case 'Torque Constant (N.m / A_peak)'

        torqueCst=torqueConstant;
        fluxCst=torqueCst/(polePairs*sqrt(3)/(cos(min(flatArea,60)*pi/360)));
    end
