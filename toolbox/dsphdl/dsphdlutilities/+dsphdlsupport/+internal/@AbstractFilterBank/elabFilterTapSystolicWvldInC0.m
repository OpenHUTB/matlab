function filterTap=elabFilterTapSystolicWvldInC0(this,topNet,blockInfo,dataRate,...
    din1,addin,enb,syncReset,...
    dinDly,tapout,tapoutVld,...
    DATA_WORDLENGTH,DATA_FRACTIONLENGTH,...
    COEF_WORDLENGTH,COEF_FRACTIONLENGTH,...
    OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH)








    InportNames={din1.Name,addin.Name,enb.Name,syncReset.Name};
    InportTypes=[din1.Type,addin.Type,enb.Type,syncReset.Type];
    InportRates=[dataRate;dataRate;dataRate;dataRate];

    OutportNames={dinDly.Name,tapout.Name,tapoutVld.Name};
    OutportTypes=[dinDly.Type,tapout.Type,tapoutVld.Type];

    filterTap=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','FilterTapSystolicWvldInC0',...
    'InportNames',InportNames,...
    'InportTypes',InportTypes,...
    'InportRates',InportRates,...
    'OutportNames',OutportNames,...
    'OutportTypes',OutportTypes...
    );

    inputPort=filterTap.PirInputSignals;
    outputPort=filterTap.PirOutputSignals;
    din1=inputPort(1);
    addin=inputPort(2);
    enb=inputPort(3);
    if blockInfo.inMode(2)
        syncReset=inputPort(4);
    else
        syncReset='';
    end
    dinDly=outputPort(1);
    tapout=outputPort(2);
    tapoutVld=outputPort(3);
    pirelab.getIntDelayEnabledResettableComp(filterTap,enb,tapoutVld,'',syncReset,blockInfo.TAP_LATENCY);


    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
    '+dsphdlsupport','+internal','@AbstractFilterBank','cgireml','FilterTapSystolicWvldInC0.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char')';
    fclose(fid);

    desc='FilterTapSystolicWvldInC0';

    tap=filterTap.addComponent2(...
    'kind','cgireml',...
    'Name','fTap',...
    'InputSignals',[din1,addin,enb],...
    'OutputSignals',[dinDly,tapout],...
    'EMLFileName','FilterTapSystolicWvldInC0',...
    'EMLFileBody',fcnBody,...
    'EMLParams',{DATA_WORDLENGTH,DATA_FRACTIONLENGTH...
    ,COEF_WORDLENGTH,COEF_FRACTIONLENGTH,...
    OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH},...
    'ExternalSynchronousResetSignal',syncReset,...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'EMLFlag_TreatInputBoolsAsUfix1',false,...
    'BlockComment',desc);

    tap.runConcurrencyMaximizer(0);
    if blockInfo.HDLGlobalReset
        tap.resetNone(false);
    else
        tap.resetNone(true);
    end

end


