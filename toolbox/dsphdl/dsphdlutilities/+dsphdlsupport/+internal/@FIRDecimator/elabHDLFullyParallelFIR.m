function FIRFullyParallel=elabHDLFullyParallelFIR(this,FilterImpl,blockInfo,insignals,outsignals)






    din=insignals;
    dout=outsignals;

    dataRate=din(1).simulinkRate;
    InportNames={din(1).Name};
    InportTypes=[din(1).Type];
    InportRates=[dataRate];

    for loop=2:length(din)
        InportNames{end+1}=din(loop).Name;
        InportTypes=[InportTypes;din(loop).Type];%#ok<*AGROW>
        InportRates=[InportRates;dataRate];
    end

    OutportNames={dout(1).Name};
    OutportTypes=[dout(1).Type];
    for loop=2:length(dout)
        OutportNames{end+1}=dout(loop).Name;
        OutportTypes=[OutportTypes;dout(loop).Type];
    end

    Name='FIRPartlySerial';

    FIRFullyParallel=pirelab.createNewNetwork(...
    'Network',FilterImpl,...
    'Name',Name,...
    'InportNames',InportNames,...
    'InportTypes',InportTypes,...
    'InportRates',InportRates,...
    'OutportNames',OutportNames,...
    'OutportTypes',OutportTypes...
    );

    FIRFilter=dsphdlsupport.internal.AbstractFilterBank;
    FIRFilter.elabHDLFilterBank(FIRFullyParallel,blockInfo);




    for loop=2:length(FilterImpl.PirInputSignals)
        FIRFullyParallel.PirInputSignals(loop).SimulinkRate=FIRFullyParallel.PirInputSignals(1).SimulinkRate;
    end

end

