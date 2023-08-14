function FilterBankImpl=elabHDLFIRFilter(this,FilterImpl,blockInfo,insignals,outsignals)





    FilterBlkInfo=getFilterBlkInfo(this,blockInfo);

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
    if FilterBlkInfo.CompiledInputSize==1
        Name='FilterBank';
    else
        Name='Filter';
    end

    FilterBankImpl=pirelab.createNewNetwork(...
    'Network',FilterImpl,...
    'Name','Filter',...
    'InportNames',InportNames,...
    'InportTypes',InportTypes,...
    'InportRates',InportRates,...
    'OutportNames',OutportNames,...
    'OutportTypes',OutportTypes...
    );




    if FilterBlkInfo.CompiledInputSize==1
        FilterBank=dsphdlsupport.internal.AbstractFilterBank;
        FilterBank.elabHDLFilterBank(FilterBankImpl,FilterBlkInfo);
    else
        this.elabHDLFilterBankV(FilterBankImpl,FilterBlkInfo);

    end

    for loop=2:length(FilterImpl.PirInputSignals)
        FilterBankImpl.PirInputSignals(loop).SimulinkRate=FilterBankImpl.PirInputSignals(1).SimulinkRate;
    end

end

