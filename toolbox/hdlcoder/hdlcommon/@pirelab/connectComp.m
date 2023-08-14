function connectComp(hC,hInSignals,hOutSignals)




    for ii=1:length(hInSignals)
        inSig=hInSignals(ii);
        inSig.addReceiver(hC,ii-1);
    end

    for ii=1:length(hOutSignals)
        outSig=hOutSignals(ii);
        outSig.addDriver(hC,ii-1);
    end