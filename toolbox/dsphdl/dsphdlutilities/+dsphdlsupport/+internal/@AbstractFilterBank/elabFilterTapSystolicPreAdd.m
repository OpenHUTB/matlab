function filterTap=elabFilterTapSystolicPreAdd(this,topNet,blockInfo,dataRate,...
    din1,din2,coef,addin,syncReset,...
    dinDly,tapout,...
    DATA_WORDLENGTH,DATA_FRACTIONLENGTH,...
    COEF_WORDLENGTH,COEF_FRACTIONLENGTH,...
    OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH,ISSYMMETRIC)








    InportNames={din1.Name,din2.Name,coef.Name,addin.Name,syncReset.Name};
    InportTypes=[din1.Type,din2.Type,coef.Type,addin.Type,syncReset.Type];
    InportRates=[dataRate;dataRate;dataRate;dataRate;dataRate];

    OutportNames={dinDly.Name,tapout.Name};
    OutportTypes=[dinDly.Type,tapout.Type];

    filterTap=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','FilterTapSystolicPreAdd',...
    'InportNames',InportNames,...
    'InportTypes',InportTypes,...
    'InportRates',InportRates,...
    'OutportNames',OutportNames,...
    'OutportTypes',OutportTypes...
    );

    inputPort=filterTap.PirInputSignals;
    outputPort=filterTap.PirOutputSignals;
    din1=inputPort(1);
    din2=inputPort(2);
    coef=inputPort(3);
    addin=inputPort(4);
    if blockInfo.inMode(2)
        syncReset=inputPort(5);
    else
        syncReset='';
    end
    dinDly=outputPort(1);
    tapout=outputPort(2);



    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
    '+dsphdlsupport','+internal','@AbstractFilterBank','cgireml','FilterTapSystolicPreAdd.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char')';
    fclose(fid);

    desc='FilterTapSystolicPreAdd';

    tap=filterTap.addComponent2(...
    'kind','cgireml',...
    'Name','fTap',...
    'InputSignals',[din1,din2,coef,addin],...
    'OutputSignals',[dinDly,tapout],...
    'EMLFileName','FilterTapSystolicPreAdd',...
    'EMLFileBody',fcnBody,...
    'EMLParams',{DATA_WORDLENGTH,DATA_FRACTIONLENGTH...
    ,COEF_WORDLENGTH,COEF_FRACTIONLENGTH,...
    OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH,...
    ISSYMMETRIC,blockInfo.synthesisTool},...
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


