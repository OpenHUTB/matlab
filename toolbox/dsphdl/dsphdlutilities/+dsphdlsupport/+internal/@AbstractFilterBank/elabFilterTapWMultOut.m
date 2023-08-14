function filterTap=elabFilterTapWMultOut(this,topNet,blockInfo,dataRate,...
    din,coef,addin,multVld,syncReset,...
    tapout,multOut,...
    DATA_WORDLENGTH,DATA_FRACTIONLENGTH,...
    COEF_WORDLENGTH,COEF_FRACTIONLENGTH,...
    OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH)







    InportNames={din.Name,coef.Name,addin.Name,multVld.Name,syncReset.Name};
    InportTypes=[din.Type,coef.Type,addin.Type,multVld.Type,syncReset.Type];
    InportRates=[dataRate;dataRate;dataRate;dataRate;dataRate];

    OutportNames={tapout.Name,multOut.Name};
    OutportTypes=[tapout.Typ,multOut.Type];

    filterTap=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','FilterTapWMultOut',...
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
    multVld=inputPort(4);
    if blockInfo.inMode(2)
        syncReset=inputPort(5);
    else
        syncReset='';
    end

    tapout=outputPort(1);
    multOut=outputPort(2);



    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
    '+dsphdlsupport','+internal','@AbstractFilterBank','cgireml','FilterTapWMultOut.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char')';
    fclose(fid);

    desc='FilterTapWMultOut';

    tap=filterTap.addComponent2(...
    'kind','cgireml',...
    'Name','fTap',...
    'InputSignals',[din,coef,addin,multVld],...
    'OutputSignals',[tapout,multOut],...
    'EMLFileName','FilterTapWMultOut',...
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


