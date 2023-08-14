function sdf1=elabRADIX22FFT_SDNF1X(this,topNet,blockInfo,R2StageNum,dataRate,BITREVERSEDINPUT,multByOne1,multByOne2,...
    DATA_WORDLENGTH,DATA_FRACTIONLENGTH,TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH,NORMALIZE,...
    din1_re,din1_im,din2_re,din2_im,din_vld,...
    twdl1_re,twdl1_im,twdl2_re,twdl2_im,twdl_vld,softReset,...
    dout1_re,dout1_im,dout2_re,dout2_im,dout_vld)






    InportNames={din1_re.Name,din1_im.Name,din2_re.Name,din2_im.Name,din_vld.Name,twdl1_re.Name,twdl1_im.Name,twdl2_re.Name,twdl2_im.Name,twdl_vld.Name,softReset.Name};
    InportTypes=[din1_re.Type;din1_im.Type;din2_re.Type;din2_im.Type;din_vld.Type;twdl1_re.Type;twdl1_im.Type;twdl2_re.Type;twdl2_im.Type;twdl_vld.Type;softReset.Type];
    InportRates=[dataRate;dataRate;dataRate;dataRate;dataRate;dataRate;dataRate;dataRate;dataRate;dataRate;dataRate];

    OutportNames={dout1_re.Name,dout1_im.Name,dout2_re.Name,dout2_im.Name,dout_vld.Name};
    OutportTypes=[dout1_re.Type;dout1_im.Type;dout2_re.Type;dout2_im.Type;dout_vld.Type];

    sdf1=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name',['RADIX22FFT_SDNF1_',int2str(R2StageNum)],...
    'InportNames',InportNames,...
    'InportTypes',InportTypes,...
    'InportRates',InportRates,...
    'OutportNames',OutportNames,...
    'OutportTypes',OutportTypes...
    );

    inputPort=sdf1.PirInputSignals;
    outputPort=sdf1.PirOutputSignals;

    if inputPort(1).Type.WordLength==outputPort(1).Type.WordLength
        din1_re=inputPort(1);
        din1_im=inputPort(2);
        din2_re=inputPort(3);
        din2_im=inputPort(4);
    else
        din1_re=sdf1.addSignal2('Type',dout1_re.Type,'Name','din_re');
        din1_re.SimulinkRate=dataRate;
        din1_im=sdf1.addSignal2('Type',dout1_im.Type,'Name','din_im');
        din1_im.SimulinkRate=dataRate;
        din2_re=sdf1.addSignal2('Type',dout2_re.Type,'Name','din_re');
        din2_re.SimulinkRate=dataRate;
        din2_im=sdf1.addSignal2('Type',dout2_im.Type,'Name','din_im');
        din2_im.SimulinkRate=dataRate;

        pirelab.getDTCComp(sdf1,inputPort(1),din1_re);
        pirelab.getDTCComp(sdf1,inputPort(2),din1_im);
        pirelab.getDTCComp(sdf1,inputPort(3),din2_re);
        pirelab.getDTCComp(sdf1,inputPort(4),din2_im);
    end
    din_vld=inputPort(5);
    twdl1_re=inputPort(6);
    twdl1_im=inputPort(7);
    twdl2_re=inputPort(8);
    twdl2_im=inputPort(9);
    twdl_vld=inputPort(10);
    softReset=inputPort(11);

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



    dinXTwdl1_re=sdf1.addSignal2('Type',pir_fixpt_t(1,DATA_WORDLENGTH,DATA_FRACTIONLENGTH),'Name','dinXTwdl1_re');
    dinXTwdl1_re.SimulinkRate=dataRate;
    dinXTwdl1_im=sdf1.addSignal2('Type',pir_fixpt_t(1,DATA_WORDLENGTH,DATA_FRACTIONLENGTH),'Name','dinXTwdl1_im');
    dinXTwdl1_im.SimulinkRate=dataRate;
    dinXTwdl2_re=sdf1.addSignal2('Type',pir_fixpt_t(1,DATA_WORDLENGTH,DATA_FRACTIONLENGTH),'Name','dinXTwdl2_re');
    dinXTwdl2_re.SimulinkRate=dataRate;
    dinXTwdl2_im=sdf1.addSignal2('Type',pir_fixpt_t(1,DATA_WORDLENGTH,DATA_FRACTIONLENGTH),'Name','dinXTwdl2_im');
    dinXTwdl2_im.SimulinkRate=dataRate;
    dinXTwdl1_vld=sdf1.addSignal2('Type',pir_boolean_t,'Name','dinXTwdl1_vld');
    dinXTwdl1_vld.SimulinkRate=dataRate;
    dinXTwdl2_vld=sdf1.addSignal2('Type',pir_boolean_t,'Name','dinXTwdl2_vld');
    dinXTwdl2_vld.SimulinkRate=dataRate;

    if~BITREVERSEDINPUT



        din1_vld=din_vld;
        for loop=1:9
            din1_re_dly=sdf1.addSignal2('Type',dout1_re.Type,'Name',['din1_re_dly',int2str(loop)]);
            din1_re_dly.SimulinkRate=dataRate;
            din1_im_dly=sdf1.addSignal2('Type',dout1_im.Type,'Name',['din1_im_dly',int2str(loop)]);
            din1_im_dly.SimulinkRate=dataRate;
            din_vld_dly=sdf1.addSignal2('Type',pir_boolean_t,'Name',['din_vld_dly',int2str(loop)]);
            din_vld_dly.SimulinkRate=dataRate;
            pirelab.getIntDelayEnabledResettableComp(sdf1,din1_re,din1_re_dly,'',syncReset,1);
            pirelab.getIntDelayEnabledResettableComp(sdf1,din1_im,din1_im_dly,'',syncReset,1);
            pirelab.getIntDelayEnabledResettableComp(sdf1,din1_vld,din_vld_dly,'',syncReset,1);
            din1_re=din1_re_dly;
            din1_im=din1_im_dly;
            din1_vld=din_vld_dly;
        end
        dinXTwdl1_re=din1_re_dly;
        dinXTwdl1_im=din1_im_dly;
        dinXTwdl1_vld=din_vld_dly;


















































        if strcmpi(blockInfo.ComplexMultiplication,'Use 3 multipliers and 5 adders')
            din2_vld=din_vld;
            for loop=1:3
                din2_re_dly=sdf1.addSignal2('Type',dout2_re.Type,'Name',['din2_re_dly',int2str(loop)]);
                din2_re_dly.SimulinkRate=dataRate;
                din2_im_dly=sdf1.addSignal2('Type',dout2_im.Type,'Name',['din2_im_dly',int2str(loop)]);
                din2_im_dly.SimulinkRate=dataRate;
                din2_vld_dly=sdf1.addSignal2('Type',pir_boolean_t,'Name',['di2_vld_dly',int2str(loop)]);
                din2_vld_dly.SimulinkRate=dataRate;
                pirelab.getIntDelayEnabledResettableComp(sdf1,din2_re,din2_re_dly,'',syncReset,1);
                pirelab.getIntDelayEnabledResettableComp(sdf1,din2_im,din2_im_dly,'',syncReset,1);
                pirelab.getIntDelayEnabledResettableComp(sdf1,din2_vld,din2_vld_dly,'',syncReset,1);
                din2_re=din2_re_dly;
                din2_im=din2_im_dly;
                din2_vld=din2_vld_dly;
            end
            MUL3=this.elabComplex3Multiply(sdf1,blockInfo,DATA_WORDLENGTH,DATA_FRACTIONLENGTH,TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH,dataRate,...
            din2_re,din2_im,din2_vld,twdl2_re,twdl2_im,softReset,dinXTwdl2_re,dinXTwdl2_im,dinXTwdl1_vld);
            pirelab.instantiateNetwork(sdf1,MUL3,[din2_re,din2_im,din2_vld,twdl2_re,twdl2_im,softReset],[dinXTwdl2_re,dinXTwdl2_im,dinXTwdl2_vld],...
            'MUL3_2');
        else
            din2_vld=din_vld;
            for loop=1:3
                din2_re_dly=sdf1.addSignal2('Type',dout2_re.Type,'Name',['din2_re_dly',int2str(loop)]);
                din2_re_dly.SimulinkRate=dataRate;
                din2_im_dly=sdf1.addSignal2('Type',dout2_im.Type,'Name',['din2_im_dly',int2str(loop)]);
                din2_im_dly.SimulinkRate=dataRate;
                din2_vld_dly=sdf1.addSignal2('Type',pir_boolean_t,'Name',['di2_vld_dly',int2str(loop)]);
                din2_vld_dly.SimulinkRate=dataRate;
                pirelab.getIntDelayEnabledResettableComp(sdf1,din2_re,din2_re_dly,'',syncReset,1);
                pirelab.getIntDelayEnabledResettableComp(sdf1,din2_im,din2_im_dly,'',syncReset,1);
                pirelab.getIntDelayEnabledResettableComp(sdf1,din2_vld,din2_vld_dly,'',syncReset,1);
                din2_re=din2_re_dly;
                din2_im=din2_im_dly;
                din2_vld=din2_vld_dly;
            end
            MUL4=this.elabComplex4Multiply(sdf1,blockInfo,DATA_WORDLENGTH,DATA_FRACTIONLENGTH,TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH,dataRate,...
            din2_re,din2_im,din2_vld,twdl2_re,twdl2_im,softReset,dinXTwdl2_re,dinXTwdl2_im,dinXTwdl1_vld);
            pirelab.instantiateNetwork(sdf1,MUL4,[din2_re,din2_im,din2_vld,twdl2_re,twdl2_im,softReset],[dinXTwdl2_re,dinXTwdl2_im,dinXTwdl2_vld],...
            'MUL4_2');
        end
    else

        din1_vld=din_vld;
        for loop=1:9
            din1_re_dly=sdf1.addSignal2('Type',dout1_re.Type,'Name',['din1_re_dly',int2str(loop)]);
            din1_re_dly.SimulinkRate=dataRate;
            din1_im_dly=sdf1.addSignal2('Type',dout1_im.Type,'Name',['din1_im_dly',int2str(loop)]);
            din1_im_dly.SimulinkRate=dataRate;
            din_vld_dly=sdf1.addSignal2('Type',pir_boolean_t,'Name',['din_vld_dly',int2str(loop)]);
            din_vld_dly.SimulinkRate=dataRate;
            pirelab.getIntDelayEnabledResettableComp(sdf1,din1_re,din1_re_dly,'',syncReset,1);
            pirelab.getIntDelayEnabledResettableComp(sdf1,din1_im,din1_im_dly,'',syncReset,1);
            pirelab.getIntDelayEnabledResettableComp(sdf1,din1_vld,din_vld_dly,'',syncReset,1);
            din1_re=din1_re_dly;
            din1_im=din1_im_dly;
            din1_vld=din_vld_dly;
        end
        dinXTwdl1_re=din1_re_dly;
        dinXTwdl1_im=din1_im_dly;
        dinXTwdl1_vld=din_vld_dly;










































        if multByOne2
            for loop=1:9
                din2_re_dly=sdf1.addSignal2('Type',dout1_re.Type,'Name',['din2_re_dly',int2str(loop)]);
                din2_re_dly.SimulinkRate=dataRate;
                din2_im_dly=sdf1.addSignal2('Type',dout1_im.Type,'Name',['din2_im_dly',int2str(loop)]);
                din2_im_dly.SimulinkRate=dataRate;
                din2_vld_dly=sdf1.addSignal2('Type',pir_boolean_t,'Name',['din2_vld_dly',int2str(loop)]);
                din2_vld_dly.SimulinkRate=dataRate;
                pirelab.getIntDelayEnabledResettableComp(sdf1,din2_re,din2_re_dly,'',syncReset,1);
                pirelab.getIntDelayEnabledResettableComp(sdf1,din2_im,din2_im_dly,'',syncReset,1);
                din2_re=din2_re_dly;
                din2_im=din2_im_dly;
            end
            dinXTwdl2_re=din2_re_dly;
            dinXTwdl2_im=din2_im_dly;





        elseif strcmpi(blockInfo.ComplexMultiplication,'Use 3 multipliers and 5 adders')
            din2_vld=din_vld;
            for loop=1:3
                din2_re_dly=sdf1.addSignal2('Type',dout2_re.Type,'Name',['din2_re_dly',int2str(loop)]);
                din2_re_dly.SimulinkRate=dataRate;
                din2_im_dly=sdf1.addSignal2('Type',dout2_im.Type,'Name',['din2_im_dly',int2str(loop)]);
                din2_im_dly.SimulinkRate=dataRate;
                din2_vld_dly=sdf1.addSignal2('Type',pir_boolean_t,'Name',['di2_vld_dly',int2str(loop)]);
                din2_vld_dly.SimulinkRate=dataRate;
                pirelab.getIntDelayEnabledResettableComp(sdf1,din2_re,din2_re_dly,'',syncReset,1);
                pirelab.getIntDelayEnabledResettableComp(sdf1,din2_im,din2_im_dly,'',syncReset,1);
                pirelab.getIntDelayEnabledResettableComp(sdf1,din2_vld,din2_vld_dly,'',syncReset,1);
                din2_re=din2_re_dly;
                din2_im=din2_im_dly;
                din2_vld=din2_vld_dly;
            end
            MUL3=this.elabComplex3Multiply(sdf1,blockInfo,DATA_WORDLENGTH,DATA_FRACTIONLENGTH,TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH,dataRate,...
            din2_re,din2_im,din2_vld,twdl2_re,twdl2_im,softReset,dinXTwdl2_re,dinXTwdl2_im,dinXTwdl1_vld);
            pirelab.instantiateNetwork(sdf1,MUL3,[din2_re,din2_im,din2_vld,twdl2_re,twdl2_im,softReset],[dinXTwdl2_re,dinXTwdl2_im,dinXTwdl2_vld],...
            'MUL3_2');
        else
            din2_vld=din_vld;
            for loop=1:3
                din2_re_dly=sdf1.addSignal2('Type',dout2_re.Type,'Name',['din2_re_dly',int2str(loop)]);
                din2_re_dly.SimulinkRate=dataRate;
                din2_im_dly=sdf1.addSignal2('Type',dout2_im.Type,'Name',['din2_im_dly',int2str(loop)]);
                din2_im_dly.SimulinkRate=dataRate;
                din2_vld_dly=sdf1.addSignal2('Type',pir_boolean_t,'Name',['di2_vld_dly',int2str(loop)]);
                din2_vld_dly.SimulinkRate=dataRate;
                pirelab.getIntDelayEnabledResettableComp(sdf1,din2_re,din2_re_dly,'',syncReset,1);
                pirelab.getIntDelayEnabledResettableComp(sdf1,din2_im,din2_im_dly,'',syncReset,1);
                pirelab.getIntDelayEnabledResettableComp(sdf1,din2_vld,din2_vld_dly,'',syncReset,1);
                din2_re=din2_re_dly;
                din2_im=din2_im_dly;
                din2_vld=din2_vld_dly;
            end
            MUL4=this.elabComplex4Multiply(sdf1,blockInfo,DATA_WORDLENGTH,DATA_FRACTIONLENGTH,TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH,dataRate,...
            din2_re,din2_im,din2_vld,twdl2_re,twdl2_im,softReset,dinXTwdl2_re,dinXTwdl2_im,dinXTwdl1_vld);
            pirelab.instantiateNetwork(sdf1,MUL4,[din2_re,din2_im,din2_vld,twdl2_re,twdl2_im,softReset],[dinXTwdl2_re,dinXTwdl2_im,dinXTwdl2_vld],...
            'MUL4_2');
        end
    end



    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
    '+dsphdlsupport','+internal','@AbstractFFT','cgireml','Radix22ButterflyG1_NF.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char')';
    fclose(fid);

    desc='Radix22ButterflyG1_NF';

    Radix22ButterflyG1_NF=sdf1.addComponent2(...
    'kind','cgireml',...
    'Name','Radix22ButterflyG1_NF',...
    'InputSignals',[dinXTwdl1_re,dinXTwdl1_im,dinXTwdl2_re,dinXTwdl2_im,dinXTwdl1_vld],...
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

