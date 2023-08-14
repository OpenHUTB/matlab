function sdnf2=elabRADIX22FFT_SDNF2(this,topNet,blockInfo,stageNum,dataRate,...
    DATA_WORDLENGTH,DATA_FRACTIONLENGTH,NORMALIZE,...
    multiply_J,...
    din1_re,din1_im,din2_re,din2_im,din_vld,softReset,...
    dout1_re,dout1_im,dout2_re,dout2_im,dout_vld)






    InportNames={multiply_J.Name,din1_re.Name,din1_im.Name,din2_re.Name,din2_im.Name,din_vld.Name,softReset.Name};
    InportTypes=[multiply_J.Type;din1_re.Type;din1_im.Type;din2_re.Type;din2_im.Type;din_vld.Type;softReset.Type];
    InportRates=[dataRate;dataRate;dataRate;dataRate;dataRate;dataRate;dataRate];

    OutportNames={dout1_re.Name,dout1_im.Name,dout2_re.Name,dout2_im.Name,dout_vld.Name};
    OutportTypes=[dout1_re.Type;dout1_im.Type;dout2_re.Type;dout2_im.Type;dout_vld.Type];

    sdnf2=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name',['RADIX22FFT_SDNF2_',int2str(stageNum)],...
    'InportNames',InportNames,...
    'InportTypes',InportTypes,...
    'InportRates',InportRates,...
    'OutportNames',OutportNames,...
    'OutportTypes',OutportTypes...
    );

    inputPort=sdnf2.PirInputSignals;
    outputPort=sdnf2.PirOutputSignals;

    multiply_J=inputPort(1);
    if inputPort(2).Type.WordLength==outputPort(1).Type.WordLength
        din1_re=inputPort(2);
        din1_im=inputPort(3);
        din2_re=inputPort(4);
        din2_im=inputPort(5);
    else
        din1_re=sdnf2.addSignal2('Type',dout1_re.Type,'Name','din1_re');
        din1_re.SimulinkRate=dataRate;
        din1_im=sdnf2.addSignal2('Type',dout1_im.Type,'Name','din1_im');
        din1_im.SimulinkRate=dataRate;
        din2_re=sdnf2.addSignal2('Type',dout2_re.Type,'Name','din2_re');
        din2_re.SimulinkRate=dataRate;
        din2_im=sdnf2.addSignal2('Type',dout2_im.Type,'Name','din2_im');
        din2_im.SimulinkRate=dataRate;
        pirelab.getDTCComp(sdnf2,inputPort(2),din1_re);
        pirelab.getDTCComp(sdnf2,inputPort(3),din1_im);
        pirelab.getDTCComp(sdnf2,inputPort(4),din2_re);
        pirelab.getDTCComp(sdnf2,inputPort(5),din2_im);
    end
    din_vld=inputPort(6);
    softReset=inputPort(7);

    ROUNDINGMETHOD=blockInfo.RoundingMethod;
    HASRESETPORT=blockInfo.inMode(2);
    if HASRESETPORT
        syncReset=softReset;
    else
        syncReset='';
    end

    dout1_re=outputPort(1);
    dout1_im=outputPort(2);
    dout2_re=outputPort(3);
    dout2_im=outputPort(4);
    dout_vld=outputPort(5);


    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
    '+dsphdlsupport','+internal','@AbstractFFT','cgireml','Radix22ButterflyG2_NF.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char')';
    fclose(fid);

    desc='Radix22ButterflyG2_NF';
    ROTATION=true;

    Radix22ButterflyG2_NF=sdnf2.addComponent2(...
    'kind','cgireml',...
    'Name','Radix22ButterflyG2_NF',...
    'InputSignals',[din1_re,din1_im,din2_re,din2_im,din_vld,multiply_J],...
    'OutputSignals',[dout1_re,dout1_im,dout2_re,dout2_im,dout_vld],...
    'ExternalSynchronousResetSignal',syncReset,...
    'EMLFileName','Radix22ButterflyG2_NF',...
    'EMLFileBody',fcnBody,...
    'EMLParams',{DATA_WORDLENGTH,DATA_FRACTIONLENGTH,NORMALIZE,ROTATION,ROUNDINGMETHOD},...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'EMLFlag_TreatInputBoolsAsUfix1',false,...
    'BlockComment',desc);

    Radix22ButterflyG2_NF.runConcurrencyMaximizer(0);
end


