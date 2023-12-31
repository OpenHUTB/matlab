function filterTap=elabFilterTapSystolicPreAddS(this,topNet,blockInfo,dataRate,...
    din1,din2,coef,addin,syncReset,...
    tapout,...
    DATA_SIGN,DATA_WORDLENGTH,DATA_FRACTIONLENGTH,...
    COEF_WORDLENGTH,COEF_FRACTIONLENGTH,...
    OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH,ISSYMMETRIC)







    if isempty(syncReset)
        InportNames={din1.Name,din2.Name,coef.Name,addin.Name};
        InportTypes=[din1.Type,din2.Type,coef.Type,addin.Type];
        InportRates=[dataRate;dataRate;dataRate;dataRate];
    else
        InportNames={din1.Name,din2.Name,coef.Name,addin.Name,syncReset.Name};
        InportTypes=[din1.Type,din2.Type,coef.Type,addin.Type,syncReset.Type];
        InportRates=[dataRate;dataRate;dataRate;dataRate;dataRate];
    end

    OutportNames={tapout.Name};
    OutportTypes=[tapout.Type];

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

    tapout=outputPort(1);
    if strcmpi(blockInfo.synthesisTool,'Altera Quartus II')
        synthesis_tool=2;
    else
        synthesis_tool=1;
    end

    dinType=pirgetdatatypeinfo(din1.Type);
    isComplex=logical(dinType.iscomplex);
    fid=fopen(fullfile(matlabroot,...
    'toolbox','dsphdl','dsphdlutilities','+dsphdlsupport','+internal',...
    '@FIRFilter','cgireml','FilterTapSystolicPreAddS.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char')';
    fclose(fid);
    if isComplex
        din1_re=filterTap.addSignal2('Type',din1.Type.BaseType,'Name','din1_re');
        din1_re.SimulinkRate=dataRate;
        din1_im=filterTap.addSignal2('Type',din1.Type.BaseType,'Name','din1_im');
        din1_im.SimulinkRate=dataRate;
        din2_re=filterTap.addSignal2('Type',din1.Type.BaseType,'Name','din2_re');
        din2_re.SimulinkRate=dataRate;
        din2_im=filterTap.addSignal2('Type',din1.Type.BaseType,'Name','din2_im');
        din2_im.SimulinkRate=dataRate;
        addin_re=filterTap.addSignal2('Type',addin.Type.BaseType,'Name','addin_re');
        addin_re.SimulinkRate=dataRate;
        addin_im=filterTap.addSignal2('Type',addin.Type.BaseType,'Name','addin_im');
        addin_im.SimulinkRate=dataRate;
        tapout_re=filterTap.addSignal2('Type',tapout.Type.BaseType,'Name','tapout_re');
        tapout_re.SimulinkRate=dataRate;
        tapout_im=filterTap.addSignal2('Type',tapout.Type.BaseType,'Name','tapout_im');
        tapout_im.SimulinkRate=dataRate;
        pirelab.getComplex2RealImag(filterTap,din1,[din1_re,din1_im],'Real and Imag');
        pirelab.getComplex2RealImag(filterTap,din2,[din2_re,din2_im],'Real and Imag');
        pirelab.getComplex2RealImag(filterTap,addin,[addin_re,addin_im],'Real and Imag');
        pirelab.getRealImag2Complex(filterTap,[tapout_re,tapout_im],tapout);

        desc='FilterTapSystolicPreAddS';

        tap_re=filterTap.addComponent2(...
        'kind','cgireml',...
        'Name','fTap',...
        'InputSignals',[din1_re,din2_re,coef,addin_re],...
        'OutputSignals',tapout_re,...
        'EMLFileName','FilterTapSystolicPreAddS',...
        'EMLFileBody',fcnBody,...
        'EMLParams',{DATA_SIGN,DATA_WORDLENGTH,DATA_FRACTIONLENGTH...
        ,COEF_WORDLENGTH,COEF_FRACTIONLENGTH,...
        OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH,...
        ISSYMMETRIC,synthesis_tool},...
        'ExternalSynchronousResetSignal',syncReset,...
        'EMLFlag_TreatInputIntsAsFixpt',true,...
        'EMLFlag_SaturateOnIntOverflow',false,...
        'EMLFlag_TreatInputBoolsAsUfix1',false,...
        'BlockComment',desc);

        tap_im=filterTap.addComponent2(...
        'kind','cgireml',...
        'Name','fTap',...
        'InputSignals',[din1_im,din2_im,coef,addin_im],...
        'OutputSignals',tapout_im,...
        'EMLFileName','FilterTapSystolicPreAddS',...
        'EMLFileBody',fcnBody,...
        'EMLParams',{DATA_SIGN,DATA_WORDLENGTH,DATA_FRACTIONLENGTH...
        ,COEF_WORDLENGTH,COEF_FRACTIONLENGTH,...
        OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH,...
        ISSYMMETRIC,synthesis_tool},...
        'ExternalSynchronousResetSignal',syncReset,...
        'EMLFlag_TreatInputIntsAsFixpt',true,...
        'EMLFlag_SaturateOnIntOverflow',false,...
        'EMLFlag_TreatInputBoolsAsUfix1',false,...
        'BlockComment',desc);


        tap_re.runConcurrencyMaximizer(0);
        tap_im.runConcurrencyMaximizer(0);
        if blockInfo.HDLGlobalReset
            tap_re.resetNone(false);
            tap_im.resetNone(false);
        else
            tap_re.resetNone(true);
            tap_im.resetNone(true);
        end
    else

        desc='FilterTapSystolicPreAddS';

        tap=filterTap.addComponent2(...
        'kind','cgireml',...
        'Name','fTap',...
        'InputSignals',[din1,din2,coef,addin],...
        'OutputSignals',tapout,...
        'EMLFileName','FilterTapSystolicPreAddS',...
        'EMLFileBody',fcnBody,...
        'EMLParams',{DATA_SIGN,DATA_WORDLENGTH,DATA_FRACTIONLENGTH...
        ,COEF_WORDLENGTH,COEF_FRACTIONLENGTH,...
        OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH,...
        ISSYMMETRIC,synthesis_tool},...
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


end


