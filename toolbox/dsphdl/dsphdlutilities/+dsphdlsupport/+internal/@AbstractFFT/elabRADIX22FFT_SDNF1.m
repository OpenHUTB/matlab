function sdnf1=elabRADIX22FFT_SDNF1(this,topNet,blockInfo,R2StageNum,dataRate,...
    DATA_WORDLENGTH,DATA_FRACTIONLENGTH,NORMALIZE,...
    din1_re,din1_im,din2_re,din2_im,din_vld,softReset,...
    dout1_re,dout1_im,dout2_re,dout2_im,dout_vld)






    InportNames={din1_re.Name,din1_im.Name,din2_re.Name,din2_im.Name,din_vld.Name,softReset.Name};
    InportTypes=[din1_re.Type;din1_im.Type;din2_re.Type;din2_im.Type;din_vld.Type;softReset.Type];
    InportRates=[dataRate;dataRate;dataRate;dataRate;dataRate;dataRate];

    OutportNames={dout1_re.Name,dout1_im.Name,dout2_re.Name,dout2_im.Name,dout_vld.Name};
    OutportTypes=[dout1_re.Type;dout1_im.Type;dout2_re.Type;dout2_im.Type;dout_vld.Type];

    sdnf1=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name',['RADIX22FFT_SDNF1_',int2str(R2StageNum)],...
    'InportNames',InportNames,...
    'InportTypes',InportTypes,...
    'InportRates',InportRates,...
    'OutportNames',OutportNames,...
    'OutportTypes',OutportTypes...
    );

    inputPort=sdnf1.PirInputSignals;
    outputPort=sdnf1.PirOutputSignals;




    din1_re=inputPort(1);
    din1_im=inputPort(2);
    din2_re=inputPort(3);
    din2_im=inputPort(4);

    din_vld=inputPort(5);
    softReset=inputPort(6);

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
    '+dsphdlsupport','+internal','@AbstractFFT','cgireml','Radix22ButterflyG1_NF.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char')';
    fclose(fid);

    desc='Radix22ButterflyG1_NF';

    Radix22ButterflyG1_NF=sdnf1.addComponent2(...
    'kind','cgireml',...
    'Name','Radix22ButterflyG1_NF',...
    'InputSignals',[din1_re,din1_im,din2_re,din2_im,din_vld],...
    'OutputSignals',[dout1_re,dout1_im,dout2_re,dout2_im,dout_vld],...
    'ExternalSynchronousResetSignal',syncReset,...
    'EMLFileName','Radix22ButterflyG1_NF',...
    'EMLFileBody',fcnBody,...
    'EMLParams',{DATA_WORDLENGTH,DATA_FRACTIONLENGTH,NORMALIZE,ROUNDINGMETHOD},...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'EMLFlag_TreatInputBoolsAsUfix1',false,...
    'BlockComment',desc);

    Radix22ButterflyG1_NF.runConcurrencyMaximizer(0);

end
