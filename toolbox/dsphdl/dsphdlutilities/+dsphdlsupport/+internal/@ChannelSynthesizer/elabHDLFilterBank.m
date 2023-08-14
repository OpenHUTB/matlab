function FilterImpl=elabHDLFilterBank(this,ChannelSynthImpl,blockInfo,insignals,outsignals)





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


    FilterImpl=pirelab.createNewNetwork(...
    'Network',ChannelSynthImpl,...
    'Name','FilterBank',...
    'InportNames',InportNames,...
    'InportTypes',InportTypes,...
    'InportRates',InportRates,...
    'OutportNames',OutportNames,...
    'OutportTypes',OutportTypes...
    );
    if blockInfo.inResetSS
        FilterImpl.setTreatNetworkAsResettableBlock;
    end

    FilterBank=dsphdlsupport.internal.AbstractFilterBank;
    FilterBank.elabHDLFilterBank(FilterImpl,FilterBlkInfo);

    for loop=2:length(ChannelSynthImpl.PirInputSignals)
        ChannelSynthImpl.PirInputSignals(loop).SimulinkRate=ChannelSynthImpl.PirInputSignals(1).SimulinkRate;
    end

end

