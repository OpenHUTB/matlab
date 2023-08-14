function scalarSignals=hdlexpandconnectiontovectorsignal(hN,vecSignal)








    narginchk(2,2);

    scalarSignals=vecSignal;
    if hdlissignalvector(vecSignal)
        scalarSignals=hdlcreatescalarsignalsfromvectorsignal(hN,vecSignal);

        pirelab.getMuxComp(hN,scalarSignals,vecSignal);
    end

end

