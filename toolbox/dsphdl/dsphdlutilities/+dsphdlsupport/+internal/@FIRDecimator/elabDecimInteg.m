function integImpl=elabDecimInteg(this,FIRDecimImpl,blockInfo,insignals,outsignals)





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


    integImpl=pirelab.createNewNetwork(...
    'Network',FIRDecimImpl,...
    'Name','FIRDecimInteg',...
    'InportNames',InportNames,...
    'InportTypes',InportTypes,...
    'InportRates',InportRates,...
    'OutportNames',OutportNames,...
    'OutportTypes',OutportTypes...
    );
    insignals=integImpl.PirInputSignals;

    outsignals=integImpl.PirOutputSignals;

    for loop=1:length(outsignals)
        outsignals(loop).SimulinkRate=insignals(1).SimulinkRate;
    end

    dataIn=insignals(1);
    dataInType=pirgetdatatypeinfo(dataIn.Type);
    dataRate=dataIn.simulinkRate;
    din_vld=insignals(2);
    din_vld.SimulinkRate=dataRate;
    if blockInfo.inMode(2)
        syncReset=insignals(3);
        syncReset.Simulinkrate=dataRate;
    else
        syncReset='';
    end

    dataOut=outsignals(1);
    dataOutType=pirgetdatatypeinfo(dataOut.Type);
    dout_vld=outsignals(2);

    DATAIN_SIGN=dataInType.issigned;
    DATAIN_WORDLENGTH=dataInType.wordsize;
    DATAIN_FRACTIONLENGTH=dataInType.binarypoint;
    DATAIN_CMPLX=dataInType.iscomplex;

    DATAOUT_SIGN=dataOutType.issigned;
    DATAOUT_WORDLENGTH=dataOutType.wordsize;
    DATAOUT_FRACTIONLENGTH=dataOutType.binarypoint;

    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
    '+dsphdlsupport','+internal','@FIRDecimator','cgireml','FIRDecimInteg.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char')';
    fclose(fid);

    desc='FIRDecimInteg';

    decimInteg=integImpl.addComponent2(...
    'kind','cgireml',...
    'Name','FIRdDecimInteg',...
    'InputSignals',[dataIn,din_vld],...
    'OutputSignals',[dataOut,dout_vld],...
    'EMLFileName','FIRDecimInteg',...
    'EMLFileBody',fcnBody,...
    'EMLParams',{DATAIN_SIGN,DATAIN_WORDLENGTH,DATAIN_FRACTIONLENGTH,DATAIN_CMPLX,blockInfo.FINALDECIM,...
    DATAOUT_SIGN,DATAOUT_WORDLENGTH,DATAOUT_FRACTIONLENGTH,blockInfo.RoundingMethod,blockInfo.OverflowAction},...
    'ExternalSynchronousResetSignal',syncReset,...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'EMLFlag_TreatInputBoolsAsUfix1',false,...
    'BlockComment',desc);

    decimInteg.runConcurrencyMaximizer(0);


    for loop=2:length(FIRDecimImpl.PirInputSignals)
        FIRDecimImpl.PirInputSignals(loop).SimulinkRate=FIRDecimImpl.PirInputSignals(1).SimulinkRate;
    end
end

