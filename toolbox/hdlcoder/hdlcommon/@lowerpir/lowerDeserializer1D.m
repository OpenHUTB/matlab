function hNewC=lowerDeserializer1D(hN,hC)




    hInSignals=hC.PirInputSignals;
    CInfo.DatainSignal=hInSignals(1);
    CInfo.startInSignal=[];
    CInfo.validInSignal=[];

    index=2;
    if hC.getStartInPort
        CInfo.startInSignal=hInSignals(index);
        index=index+1;
    end
    if hC.getValidInPort
        CInfo.validInSignal=hInSignals(index);
    end



    hOutSignal=hC.PirOutputSignals;
    CInfo.DataoutSignal=hOutSignal(1);
    CInfo.validOutSignal=[];

    if hC.getValidOutPort
        CInfo.validOutSignal=hOutSignal(2);
    end



    hNewC=pireml.getDeserializer1DComp(...
    'Network',hN,...
    'Name',hC.Name,...
    'DatainSignal',CInfo.DatainSignal,...
    'startInSignal',CInfo.startInSignal,...
    'validInSignal',CInfo.validInSignal,...
    'DataoutSignal',CInfo.DataoutSignal,...
    'validOutSignal',CInfo.validOutSignal,...
    'Ratio',hC.getRatio,...
    'IdleCycles',hC.getIdleCycles,...
    'InitialValue',hC.getInitialValue);

end


