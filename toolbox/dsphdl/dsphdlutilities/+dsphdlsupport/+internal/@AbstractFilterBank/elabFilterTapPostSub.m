function filterTap=elabFilterTapPostSub(this,topNet,blockInfo,dataRate,...
    addin,multIn,multVld,syncReset,...
    tapout,...
    DATA_WORDLENGTH,DATA_FRACTIONLENGTH,...
    COEF_WORDLENGTH,COEF_FRACTIONLENGTH,...
    OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH)







    InportNames={addin.Name,multIn.Name,multVld.Name,syncReset.Name};
    InportTypes=[addin.Type,multIn.Type,multVld.Type,syncReset.Type];
    InportRates=[dataRate;dataRate;dataRate;dataRate];

    OutportNames={tapout.Name};
    OutportTypes=[tapout.Typ];

    filterTap=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','FilterTapPostSub',...
    'InportNames',InportNames,...
    'InportTypes',InportTypes,...
    'InportRates',InportRates,...
    'OutportNames',OutportNames,...
    'OutportTypes',OutportTypes...
    );

    inputPort=filterTap.PirInputSignals;
    outputPort=filterTap.PirOutputSignals;

    addin=inputPort(1);
    multIn=inputPort(2);
    multVld=inputPort(3);
    if blockInfo.inMode(2)
        syncReset=inputPort(4);
    else
        syncReset='';
    end
    tapout=outputPort(1);



    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
    '+dsphdlsupport','+internal','@AbstractFilterBank','cgireml','FilterTapPostSub.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char')';
    fclose(fid);

    desc='FilterTapPostSub';

    tap=filterTap.addComponent2(...
    'kind','cgireml',...
    'Name','fTap',...
    'InputSignals',[addin,multIn,multVld],...
    'OutputSignals',[tapout],...
    'EMLFileName','FilterTapPostSub',...
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


