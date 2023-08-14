function filterTap=elabFilterTapSystolicWvldIn(this,topNet,blockInfo,dataRate,...
    din,coef,addin,vldIn,syncReset,...
    dinDly,tapout,tapoutVld,...
    DATA_WORDLENGTH,DATA_FRACTIONLENGTH,...
    COEF_WORDLENGTH,COEF_FRACTIONLENGTH,...
    OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH)







    InportNames={din.Name,coef.Name,addin.Name,vldIn.Name,syncReset.Name};
    InportTypes=[din.Type,coef.Type,addin.Type,vldIn.Type,syncReset.Type];
    InportRates=[dataRate;dataRate;dataRate;dataRate;dataRate];

    OutportNames={dinDly.Name,tapout.Name,tapoutVld.Name};
    OutportTypes=[dinDly.Type,tapout.Type,tapoutVld.Type];

    filterTap=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','FilterTapSystolicWvldin',...
    'InportNames',InportNames,...
    'InportTypes',InportTypes,...
    'InportRates',InportRates,...
    'OutportNames',OutportNames,...
    'OutportTypes',OutportTypes...
    );

    inputPort=filterTap.PirInputSignals;
    outputPort=filterTap.PirOutputSignals;
    din=inputPort(1);
    coef=inputPort(2);
    addin=inputPort(3);
    vldIn=inputPort(4);
    if blockInfo.inMode(2)
        syncReset=inputPort(5);
    else
        syncReset='';
    end
    dinDly=outputPort(1);
    tapout=outputPort(2);
    tapoutVld=outputPort(3);

    pirelab.getIntDelayEnabledResettableComp(filterTap,vldIn,tapoutVld,'',syncReset,blockInfo.TAP_LATENCY);



    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
    '+dsphdlsupport','+internal','@AbstractFilterBank','cgireml','FilterTapSystolicWvldIn.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char')';
    fclose(fid);

    desc='FilterTapSystlicWvldIn';

    tap=filterTap.addComponent2(...
    'kind','cgireml',...
    'Name','fTap',...
    'InputSignals',[din,coef,addin,vldIn],...
    'OutputSignals',[dinDly,tapout],...
    'EMLFileName','FilterTapSystolicWvldIn',...
    'EMLFileBody',fcnBody,...
    'EMLParams',{DATA_WORDLENGTH,DATA_FRACTIONLENGTH...
    ,COEF_WORDLENGTH,COEF_FRACTIONLENGTH,...
    OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH,blockInfo.synthesisTool},...
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


