function CtrlImpl=elabPartlySerialCtrl(this,FIRDecimImpl,blockInfo,inSignals,outSignals)




    dataRate=inSignals(1).simulinkRate;

    InportNames={inSignals(1).Name};
    InportTypes=[inSignals(1).Type];
    InportRates=dataRate;
    for loop=2:length(inSignals)
        InportNames{end+1}=inSignals(loop).Name;
        InportTypes=[InportTypes;inSignals(loop).Type];%#ok<*AGROW>
        InportRates=[InportRates;dataRate];
    end

    OutportNames={outSignals(1).Name,outSignals(2).Name};
    OutportTypes=[outSignals(1).Type;outSignals(2).Type];

    CtrlImpl=pirelab.createNewNetwork(...
    'Network',FIRDecimImpl,...
    'Name','partlySerialCtrl',...
    'InportNames',InportNames,...
    'InportTypes',InportTypes,...
    'InportRates',InportRates,...
    'OutportNames',OutportNames,...
    'OutportTypes',OutportTypes...
    );
    vldIn=CtrlImpl.PirInputSignals(1);
    if blockInfo.inMode(2)
        syncReset=CtrlImpl.PirInputSignals(2);
        syncReset.Simulinkrate=dataRate;
    else
        syncReset='';
    end

    outSig=CtrlImpl.PirOutputSignals;

    for loop=1:length(outSignals)
        outSig(loop).SimulinkRate=vldIn.SimulinkRate;
    end

    vldOut=outSig(1);
    rdy=outSig(2);

    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
    '+dsphdlsupport','+internal','@FIRDecimator','cgireml','partlySerialCtrl.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char')';
    fclose(fid);

    desc='CtrlLogic';

    cntrl=CtrlImpl.addComponent2(...
    'kind','cgireml',...
    'Name','CtrlLogic',...
    'InputSignals',vldIn,...
    'OutputSignals',[vldOut,rdy],...
    'EMLFileName','partlySerialCtrl',...
    'EMLFileBody',fcnBody,...
    'EMLParams',{blockInfo.DecimationFactor,blockInfo.NumCycles},...
    'ExternalSynchronousResetSignal',syncReset,...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'EMLFlag_TreatInputBoolsAsUfix1',false,...
    'BlockComment',desc);

    cntrl.runConcurrencyMaximizer(0);


    for loop=2:length(CtrlImpl.PirInputSignals)
        CtrlImpl.PirInputSignals(loop).SimulinkRate=FIRDecimImpl.PirInputSignals(1).SimulinkRate;
    end
end

