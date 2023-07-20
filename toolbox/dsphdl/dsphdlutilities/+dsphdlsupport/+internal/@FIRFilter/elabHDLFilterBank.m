function FilterImpl=elabHDLFilterBank(this,FilterBankImpl,blockInfo,insignals,outsignals)





    FilterBlkInfo=blockInfo;

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


    FilterImpl=pirelab.createNewNetwork(...
    'Network',FilterBankImpl,...
    'Name','FilterBank',...
    'InportNames',InportNames,...
    'InportTypes',InportTypes,...
    'InportRates',InportRates,...
    'OutportNames',OutportNames,...
    'OutportTypes',OutportTypes...
    );

    FilterBank=dsphdlsupport.internal.AbstractFilterBank;
    FilterBank.elabHDLFilterBank(FilterImpl,FilterBlkInfo);

    for loop=2:length(FilterBankImpl.PirInputSignals)
        FilterBankImpl.PirInputSignals(loop).SimulinkRate=FilterBankImpl.PirInputSignals(1).SimulinkRate;
    end

end

