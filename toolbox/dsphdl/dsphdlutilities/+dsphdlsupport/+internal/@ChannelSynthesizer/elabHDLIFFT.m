function IFFTImpl=elabHDLIFFT(this,ChannelSynthImpl,blockInfo,insignals,outsignals)





    IFFTblkInfo=getIFFTBlkInfo(this,length(insignals),blockInfo);
    din=insignals;
    dout=outsignals;

    dataRate=din(1).simulinkRate;
    InportNames={din(1).Name};
    InportTypes=[din(1).Type];
    InportRates=[dataRate];

    OutportNames={dout(1).Name};
    OutportTypes=[dout(1).Type];
    for loop=2:length(din)
        InportNames{end+1}=din(loop).Name;
        InportTypes=[InportTypes;din(loop).Type];%#ok<*AGROW>
        InportRates=[InportRates;dataRate];
    end
    for loop=2:length(dout)
        OutportNames{end+1}=dout(loop).Name;
        OutportTypes=[OutportTypes;dout(loop).Type];
    end


    IFFTImpl=pirelab.createNewNetwork(...
    'Network',ChannelSynthImpl,...
    'Name','IFFT',...
    'InportNames',InportNames,...
    'InportTypes',InportTypes,...
    'InportRates',InportRates,...
    'OutportNames',OutportNames,...
    'OutportTypes',OutportTypes...
    );

    IFFT=dsphdlsupport.internal.IFFT;
    IFFT.elaborateHDLFFTP(IFFTImpl,IFFTblkInfo);

    for loop=2:length(ChannelSynthImpl.PirInputSignals)
        ChannelSynthImpl.PirInputSignals(loop).SimulinkRate=ChannelSynthImpl.PirInputSignals(1).SimulinkRate;
    end
end

