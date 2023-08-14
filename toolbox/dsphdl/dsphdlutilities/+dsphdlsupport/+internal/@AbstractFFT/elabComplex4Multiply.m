function btf=elabComplex4Multiply(this,topNet,blockInfo,DATA_WORDLENGTH,DATA_FRACTIONLENGTH,TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH,dataRate,...
    din_re,din_im,din_vld,twdl_re,twdl_im,softReset,multRes_re,multRes_im,multRes_vld)







    btf=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','Complex4Multiply',...
    'InportNames',{din_re.Name,din_im.Name,din_vld.Name,twdl_re.Name,twdl_im.Name,softReset.Name},...
    'InportTypes',[din_re.Type;din_im.Type;din_vld.Type;twdl_re.Type;twdl_im.Type;softReset.Type],...
    'InportRates',[dataRate;dataRate;dataRate;dataRate;dataRate;dataRate],...
    'OutportNames',{multRes_re.Name,multRes_im.Name,multRes_vld.Name},...
    'OutportTypes',[multRes_re.Type;multRes_im.Type;multRes_vld.Type]...
    );


    inputPort=btf.PirInputSignals;
    outputPort=btf.PirOutputSignals;

    din_re=inputPort(1);
    din_im=inputPort(2);
    din_vld=inputPort(3);
    twdl_re=inputPort(4);
    twdl_im=inputPort(5);
    softReset=inputPort(6);

    HASRESETPORT=blockInfo.inMode(2);
    if HASRESETPORT
        syncReset=softReset;
    else
        syncReset='';
    end

    multRes_re=outputPort(1);
    multRes_im=outputPort(2);
    multRes_vld=outputPort(3);

    twdlType=pir_sfixpt_t(TWDL_WORDLENGTH,(TWDL_FRACTIONLENGTH));
    dinType=pir_sfixpt_t(DATA_WORDLENGTH,(DATA_FRACTIONLENGTH));
    multType=pir_sfixpt_t(DATA_WORDLENGTH+TWDL_WORDLENGTH,(DATA_FRACTIONLENGTH+TWDL_FRACTIONLENGTH));
    multResFP=pir_sfixpt_t(DATA_WORDLENGTH+TWDL_WORDLENGTH+1,(DATA_FRACTIONLENGTH+TWDL_FRACTIONLENGTH));

    din_re_reg=btf.addSignal2('Type',dinType,'Name','din_re_reg');
    din_re_reg.SimulinkRate=dataRate;
    din_im_reg=btf.addSignal2('Type',dinType,'Name','din_im_reg');
    din_im_reg.SimulinkRate=dataRate;
    twdl_re_reg=btf.addSignal2('Type',twdlType,'Name','twdl_re_reg');
    twdl_re_reg.SimulinkRate=dataRate;
    twdl_im_reg=btf.addSignal2('Type',twdlType,'Name','twdl_im_reg');
    twdl_im_reg.SimulinkRate=dataRate;
    prod1_re=btf.addSignal2('Type',multType,'Name','prod1_re');
    prod1_re.SimulinkRate=dataRate;
    prod1_im=btf.addSignal2('Type',multType,'Name','prod1_im');
    prod1_im.SimulinkRate=dataRate;
    prod2_re=btf.addSignal2('Type',multType,'Name','prod2_re');
    prod2_re.SimulinkRate=dataRate;
    prod2_im=btf.addSignal2('Type',multType,'Name','prod2_im');
    prod2_im.SimulinkRate=dataRate;

    multResFP_re=btf.addSignal2('Type',multResFP,'Name','mulResFP_re');
    multResFP_re.SimulinkRate=dataRate;
    multResFP_im=btf.addSignal2('Type',multResFP,'Name','mulResFP_im');
    multResFP_im.SimulinkRate=dataRate;

    din_vld_dly1=btf.addSignal2('Type',pir_boolean_t,'Name','din_vld_dly1');
    din_vld_dly1.SimulinkRate=dataRate;
    din_vld_dly2=btf.addSignal2('Type',pir_boolean_t,'Name','din_vld_dly2');
    din_vld_dly2.SimulinkRate=dataRate;
    din_vld_dly3=btf.addSignal2('Type',pir_boolean_t,'Name','din_vld_dly3');
    din_vld_dly3.SimulinkRate=dataRate;
    prod_vld=btf.addSignal2('Type',pir_boolean_t,'Name','prod_vld');
    prod_vld.SimulinkRate=dataRate;

    pirelab.getIntDelayEnabledResettableComp(btf,din_re,din_re_reg,'',syncReset,1);
    pirelab.getIntDelayEnabledResettableComp(btf,din_im,din_im_reg,'',syncReset,1);
    pirelab.getIntDelayEnabledResettableComp(btf,twdl_re,twdl_re_reg,'',syncReset,1);
    pirelab.getIntDelayEnabledResettableComp(btf,twdl_im,twdl_im_reg,'',syncReset,1);



    pirelab.getIntDelayEnabledResettableComp(btf,din_vld,din_vld_dly1,'',syncReset,1);
    pirelab.getIntDelayEnabledResettableComp(btf,din_vld_dly1,din_vld_dly2,'',syncReset,1);
    pirelab.getIntDelayEnabledResettableComp(btf,din_vld_dly2,din_vld_dly3,'',syncReset,1);
    pirelab.getIntDelayEnabledResettableComp(btf,din_vld_dly3,prod_vld,'',syncReset,1);

    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities','+dsphdlsupport','+internal',...
    '@AbstractFFT','cgireml','complex4Multiply.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char')';
    fclose(fid);

    desc='Complex4Multiply';

    Complex4Multiply=btf.addComponent2(...
    'kind','cgireml',...
    'Name','Complex4Multiply',...
    'InputSignals',[din_re_reg,din_im_reg,twdl_re_reg,twdl_im_reg],...
    'OutputSignals',[prod1_re,prod1_im,prod2_re,prod2_im],...
    'EMLFileName','complex4Multiply',...
    'EMLFileBody',fcnBody,...
    'EMLParams',{DATA_WORDLENGTH,DATA_FRACTIONLENGTH,TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH},...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'EMLFlag_TreatInputBoolsAsUfix1',false,...
    'BlockComment',desc);

    Complex4Multiply.runConcurrencyMaximizer(0);
    Complex4Multiply.resetNone(true);

    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
    '+dsphdlsupport','+internal','@AbstractFFT','cgireml','complex4Add.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char')';
    fclose(fid);

    desc='Complex4Add';
    ComplexAdd=btf.addComponent2(...
    'kind','cgireml',...
    'Name','Complex4Add',...
    'InputSignals',[prod1_re,prod2_re,prod1_im,prod2_im,prod_vld],...
    'OutputSignals',[multResFP_re,multResFP_im,multRes_vld],...
    'ExternalSynchronousResetSignal',syncReset,...
    'EMLFileName','complex4Add',...
    'EMLFileBody',fcnBody,...
    'EMLParams',{DATA_WORDLENGTH,DATA_FRACTIONLENGTH,TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH},...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'EMLFlag_TreatInputBoolsAsUfix1',false,...
    'BlockComment',desc);

    ComplexAdd.runConcurrencyMaximizer(0);
    ComplexAdd.resetNone(false);


    pirelab.getDTCComp(btf,multResFP_re,multRes_re,blockInfo.RoundingMethod);
    pirelab.getDTCComp(btf,multResFP_im,multRes_im,blockInfo.RoundingMethod);


end
