function hNewC=lowerSerializer1D(hN,hC)




    hInSignals=hC.PirInputSignals;
    CInfo.DatainSignal=hInSignals(1);
    CInfo.validInSignal=[];

    if hC.getValidInPort
        CInfo.validInSignal=hInSignals(2);
    end



    hOutSignal=hC.PirOutputSignals;
    CInfo.DataoutSignal=hOutSignal(1);
    CInfo.startOutSignal=[];
    CInfo.validOutSignal=[];

    index=2;
    if hC.getStartOutPort
        CInfo.startOutSignal=hOutSignal(index);
        index=index+1;
    end
    if hC.getValidOutPort
        CInfo.validOutSignal=hOutSignal(index);
    end



    hNewC=pireml.getSerializer1DComp(...
    'Network',hN,...
    'Name',hC.Name,...
    'DatainSignal',CInfo.DatainSignal,...
    'validInSignal',CInfo.validInSignal,...
    'DataoutSignal',CInfo.DataoutSignal,...
    'startOutSignal',CInfo.startOutSignal,...
    'validOutSignal',CInfo.validOutSignal,...
    'Ratio',hC.getRatio,...
    'IdleCycles',hC.getIdleCycles);

end


