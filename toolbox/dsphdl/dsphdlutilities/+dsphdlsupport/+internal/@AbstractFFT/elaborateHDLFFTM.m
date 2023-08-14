function elaborateHDLFFTM(this,FFTImpl,blockInfo)








    insignals=FFTImpl.PirInputSignals;

    outsignals=FFTImpl.PirOutputSignals;

    for loop=1:length(outsignals)
        outsignals(loop).SimulinkRate=insignals(1).SimulinkRate;
    end

    dataIn=insignals(1);
    dataInType=pirgetdatatypeinfo(dataIn.Type);
    dataRate=dataIn.simulinkRate;
    din_vld=insignals(2);
    din_vld.SimulinkRate=dataRate;



    if blockInfo.inMode(2)&&~blockInfo.inResetSS
        syncReset=insignals(3);
        syncReset.SimulinkRate=dataRate;
    else
        syncReset=FFTImpl.addSignal2('Type',pir_boolean_t,'Name','syncReset');
        syncReset.SimulinkRate=dataRate;
        if blockInfo.inResetSS


            syncReset.setSynthResetInsideResetSS;

            blockInfo.inMode(2)=true;
        else


            pirelab.getConstComp(FFTImpl,syncReset,false);
        end
    end

    DATA_SIGN=dataInType.issigned;
    DATA_WORDLENGTH=dataInType.wordsize;
    DATA_FRACTIONLENGTH=dataInType.binarypoint;
    DATA_VECSIZE=dataInType.dims;
    DATA_CMPLX=dataInType.iscomplex;

    if~DATA_SIGN
        DATA_WORDLENGTH=DATA_WORDLENGTH+1;
    end




    TWDL_WORDLENGTH=DATA_WORDLENGTH+(~blockInfo.Normalize)*sum(blockInfo.BitGrowthVector);
    TWDL_FRACTIONLENGTH=-(TWDL_WORDLENGTH-2);
    blockInfo.TWDL_WORDLENGTH=TWDL_WORDLENGTH;
    blockInfo.TWDL_FRACTIONLENGTH=TWDL_FRACTIONLENGTH;
    blockInfo.actualFFTLength=blockInfo.FFTLength;
    blockInfo.InputDataIsReal=~DATA_CMPLX;





    dOut_type=pir_sfixpt_t(DATA_WORDLENGTH+(~blockInfo.Normalize)*sum(blockInfo.BitGrowthVector),DATA_FRACTIONLENGTH);
    for loop=1:DATA_VECSIZE
        din_re(1,loop)=FFTImpl.addSignal2('Type',dOut_type,'Name',['din_',int2str(loop),'_re']);
        din_re(1,loop).SimulinkRate=dataRate;
        din_im(1,loop)=FFTImpl.addSignal2('Type',dOut_type,'Name',['din_',int2str(loop),'_im']);
        din_im(1,loop).SimulinkRate=dataRate;

        dataIn_cast(loop)=FFTImpl.addSignal2('Type',pir_complex_t(dOut_type),'Name',['dataIn_',int2str(loop),'_cast']);%#ok<*AGROW>
        dataIn_cast(loop).SimulinkRate=dataRate;
        if DATA_VECSIZE==1
            din_tmp=dataIn;
        else
            din_tmp=dataIn.split.PirOutputSignals(loop);
        end
        pirelab.getDTCComp(FFTImpl,din_tmp,dataIn_cast(loop));
        pirelab.getComplex2RealImag(FFTImpl,dataIn_cast(loop),[din_re(1,loop),din_im(1,loop)],'real and imag');
    end




    if blockInfo.inverseFFT
        din_tmp=din_re;
        din_re=din_im;
        din_im=din_tmp;
    end




    TOTALSTAGES=log2(blockInfo.actualFFTLength);

    btfIn1_re=FFTImpl.addSignal2('Type',dOut_type,'Name','btfIn1_re');
    btfIn1_re.SimulinkRate=dataRate;
    btfIn1_im=FFTImpl.addSignal2('Type',dOut_type,'Name','btfIn1_im');
    btfIn1_im.SimulinkRate=dataRate;
    btfIn2_re=FFTImpl.addSignal2('Type',dOut_type,'Name','btfIn2_re');
    btfIn2_re.SimulinkRate=dataRate;
    btfIn2_im=FFTImpl.addSignal2('Type',dOut_type,'Name','btfIn2_im');
    btfIn2_im.SimulinkRate=dataRate;
    btfIn_vld=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name','btfIn_vld');
    btfIn_vld.SimulinkRate=dataRate;

    btfOut1_re=FFTImpl.addSignal2('Type',dOut_type,'Name','btfOut1_re');
    btfOut1_re.SimulinkRate=dataRate;
    btfOut1_im=FFTImpl.addSignal2('Type',dOut_type,'Name','btfOut1_im');
    btfOut1_im.SimulinkRate=dataRate;
    btfOut2_re=FFTImpl.addSignal2('Type',dOut_type,'Name','btfOut2_re');
    btfOut2_re.SimulinkRate=dataRate;
    btfOut2_im=FFTImpl.addSignal2('Type',dOut_type,'Name','btfOut2_im');
    btfOut2_im.SimulinkRate=dataRate;
    btfOut_vld=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name','btfOut_vld');
    btfOut_vld.SimulinkRate=dataRate;

    stgOut1_re=FFTImpl.addSignal2('Type',dOut_type,'Name','stgOut1_re');
    stgOut1_re.SimulinkRate=dataRate;
    stgOut1_im=FFTImpl.addSignal2('Type',dOut_type,'Name','stgOut1_im');
    stgOut1_im.SimulinkRate=dataRate;
    stgOut2_re=FFTImpl.addSignal2('Type',dOut_type,'Name','stgOut2_re');
    stgOut2_re.SimulinkRate=dataRate;
    stgOut2_im=FFTImpl.addSignal2('Type',dOut_type,'Name','stgOut2_im');
    stgOut2_im.SimulinkRate=dataRate;
    stgOut_vld=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name','stgOut_vld');
    stgOut_vld.SimulinkRate=dataRate;

    dMemIn1_re=FFTImpl.addSignal2('Type',dOut_type,'Name','dMemIn1_re');
    dMemIn1_re.SimulinkRate=dataRate;
    dMemIn1_im=FFTImpl.addSignal2('Type',dOut_type,'Name','dMemIn1_im');
    dMemIn1_im.SimulinkRate=dataRate;
    dMemIn2_re=FFTImpl.addSignal2('Type',dOut_type,'Name','dMemIn2_re');
    dMemIn2_re.SimulinkRate=dataRate;
    dMemIn2_im=FFTImpl.addSignal2('Type',dOut_type,'Name','dMemIn2_im');
    dMemIn2_im.SimulinkRate=dataRate;
    dMemIn_vld=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name','dMemIn_vld');
    dMemIn_vld.SimulinkRate=dataRate;

    dMemOut1_re=FFTImpl.addSignal2('Type',dOut_type,'Name','dMemOut1_re');
    dMemOut1_re.SimulinkRate=dataRate;
    dMemOut1_im=FFTImpl.addSignal2('Type',dOut_type,'Name','dMemOut1_im');
    dMemOut1_im.SimulinkRate=dataRate;
    dMemOut2_re=FFTImpl.addSignal2('Type',dOut_type,'Name','dMemOut2_re');
    dMemOut2_re.SimulinkRate=dataRate;
    dMemOut2_im=FFTImpl.addSignal2('Type',dOut_type,'Name','dMemOut2_im');
    dMemOut2_im.SimulinkRate=dataRate;
    dMemOut_vld=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name','dMemOut_vld');
    dMemOut_vld.SimulinkRate=dataRate;
    dMemOutDly_vld=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name','dMemOutDly_vld');
    dMemOutDly_vld.SimulinkRate=dataRate;

    wrEnb1=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name','wrEnb1');
    wrEnb1.SimulinkRate=dataRate;
    wrEnb2=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name','wrEnb2');
    wrEnb2.SimulinkRate=dataRate;
    wrEnb3=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name','wrEnb3');
    wrEnb3.SimulinkRate=dataRate;
    rdEnb1=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name','rdEnb1');
    rdEnb1.SimulinkRate=dataRate;
    rdEnb2=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name','rdEnb2');
    rdEnb2.SimulinkRate=dataRate;
    rdEnb3=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name','rdEnb3');
    rdEnb3.SimulinkRate=dataRate;
    vldOut=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name','vldOut');
    vldOut.SimulinkRate=dataRate;
    rdy=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name','rdy');
    rdy.SimulinkRate=dataRate;
    initIC=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name','initIC');
    initIC.SimulinkRate=dataRate;
    unLoadPhase=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name','unLoadPhase');
    unLoadPhase.SimulinkRate=dataRate;

    stage=FFTImpl.addSignal2('Type',pir_fixpt_t(0,ceil(log2(TOTALSTAGES)),0),'Name','stage');
    stage.SimulinkRate=dataRate;
    twdl_re=FFTImpl.addSignal2('Type',pir_sfixpt_t(TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH),'Name','twdl_re');%#ok<*AGROW>
    twdl_re.SimulinkRate=dataRate;
    twdl_im=FFTImpl.addSignal2('Type',pir_sfixpt_t(TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH),'Name','twdl_im');%#ok<*AGROW>
    twdl_im.SimulinkRate=dataRate;
    twdl_vld=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name','twdl_vld');
    twdl_vld.SimulinkRate=dataRate;

    dout_re=FFTImpl.addSignal2('Type',dOut_type,'Name','dOut_re');
    dout_re.SimulinkRate=dataRate;
    dout_im=FFTImpl.addSignal2('Type',dOut_type,'Name','dOut_im');
    dout_im.SimulinkRate=dataRate;
    dout_vld=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name','dout_vld');
    dout_vld.SimulinkRate=dataRate;




    TWDLROM=elabMinResRX2FFT_TWDLROM(this,FFTImpl,dataRate,blockInfo,...
    dMemOutDly_vld,...
    stage,initIC,syncReset,...
    twdl_re,twdl_im,twdl_vld);
    pirelab.instantiateNetwork(FFTImpl,TWDLROM,...
    [dMemOutDly_vld,stage,initIC,syncReset],...
    [twdl_re,twdl_im,twdl_vld],...
    'MinResRX2FFT_TWDLROM');
    pirelab.getIntDelayEnabledResettableComp(FFTImpl,dMemOut_vld,dMemOutDly_vld,'',syncReset,1);

    CTRL=elabMinResRX2FFT_CTRL(this,FFTImpl,dataRate,blockInfo,...
    din_re,din_im,din_vld,...
    stgOut1_re,stgOut1_im,stgOut2_re,stgOut2_im,stgOut_vld,...
    syncReset,...
    dMemIn1_re,dMemIn1_im,dMemIn2_re,dMemIn2_im,...
    wrEnb1,wrEnb2,wrEnb3,rdEnb1,rdEnb2,rdEnb3,...
    dMemOut_vld,vldOut,stage,rdy,initIC,unLoadPhase);
    pirelab.instantiateNetwork(FFTImpl,CTRL,[din_re,din_im,din_vld,stgOut1_re,stgOut1_im,stgOut2_re,stgOut2_im,stgOut_vld,syncReset],...
    [dMemIn1_re,dMemIn1_im,dMemIn2_re,dMemIn2_im,wrEnb1,wrEnb2,wrEnb3,rdEnb1,rdEnb2,rdEnb3,dMemOut_vld,vldOut,stage,rdy,initIC,unLoadPhase],...
    'MinResRX2FFT_CTRL');
    MEMORY=elabMinResRX2FFT_Memory(this,FFTImpl,dataRate,blockInfo,...
    dMemIn1_re,dMemIn1_im,dMemIn2_re,dMemIn2_im,...
    wrEnb1,wrEnb2,wrEnb3,rdEnb1,rdEnb2,rdEnb3,...
    stage,initIC,unLoadPhase,syncReset,...
    dMemOut1_re,dMemOut1_im,dMemOut2_re,dMemOut2_im);
    pirelab.instantiateNetwork(FFTImpl,MEMORY,[dMemIn1_re,dMemIn1_im,dMemIn2_re,dMemIn2_im,wrEnb1,wrEnb2,wrEnb3,rdEnb1,rdEnb2,rdEnb3,stage,initIC,unLoadPhase,syncReset],...
    [dMemOut1_re,dMemOut1_im,dMemOut2_re,dMemOut2_im],...
    'MinResRX2FFT_MEMORY');

    BTFSEL=elabMinResRX2FFT_BTFSEL(this,FFTImpl,dataRate,blockInfo,...
    din_re,din_im,din_vld,rdy,...
    dMemOut1_re,dMemOut1_im,dMemOut2_re,dMemOut2_im,dMemOut_vld,...
    stage,initIC,syncReset,...
    btfIn1_re,btfIn1_im,btfIn2_re,btfIn2_im,btfIn_vld);
    pirelab.instantiateNetwork(FFTImpl,BTFSEL,[din_re,din_im,din_vld,rdy,...
    dMemOut1_re,dMemOut1_im,dMemOut2_re,dMemOut2_im,dMemOut_vld,...
    stage,initIC,syncReset],...
    [btfIn1_re,btfIn1_im,btfIn2_re,btfIn2_im,btfIn_vld],...
    'MinResRX2FFT_BTFSEL');

    BUTTERFLY=elabMinResRX2FFT_Butterfly(this,FFTImpl,dataRate,blockInfo,...
    btfIn1_re,btfIn1_im,btfIn2_re,btfIn2_im,btfIn_vld,...
    twdl_re,twdl_im,syncReset,...
    btfOut1_re,btfOut1_im,btfOut2_re,btfOut2_im,btfOut_vld);

    pirelab.instantiateNetwork(FFTImpl,BUTTERFLY,[btfIn1_re,btfIn1_im,btfIn2_re,btfIn2_im,btfIn_vld,twdl_re,twdl_im,syncReset],...
    [btfOut1_re,btfOut1_im,btfOut2_re,btfOut2_im,btfOut_vld],...
    'MinResRX2FFT_BUTTERFLY');

    MEMSEL=elabMinResRX2FFT_MEMSEL(this,FFTImpl,dataRate,blockInfo,...
    btfOut1_re,btfOut1_im,btfOut2_re,btfOut2_im,btfOut_vld,...
    stage,initIC,syncReset,...
    stgOut1_re,stgOut1_im,stgOut2_re,stgOut2_im,stgOut_vld);
    pirelab.instantiateNetwork(FFTImpl,MEMSEL,[btfOut1_re,btfOut1_im,btfOut2_re,btfOut2_im,btfOut_vld,...
    stage,initIC,syncReset],...
    [stgOut1_re,stgOut1_im,stgOut2_re,stgOut2_im,stgOut_vld],...
    'MinResRX2FFT_MEMSEL');

    OUTMUX=elabMinResRX2FFT_OUTMux(this,FFTImpl,dataRate,blockInfo,...
    rdEnb1,rdEnb2,rdEnb3,...
    dMemOut1_re,dMemOut1_im,dMemOut2_re,dMemOut2_im,vldOut,syncReset,...
    dout_re,dout_im,dout_vld);
    pirelab.instantiateNetwork(FFTImpl,OUTMUX,[rdEnb1,rdEnb2,rdEnb3,dMemOut1_re,dMemOut1_im,dMemOut2_re,dMemOut2_im,vldOut,syncReset],...
    [dout_re,dout_im,dout_vld],...
    'MinResRX2FFT_OUTMUX');





    if blockInfo.inverseFFT
        dout_tmp=dout_re;
        dout_re=dout_im;
        dout_im=dout_tmp;
    end


    VLDLEN=log2(double(blockInfo.actualFFTLength/DATA_VECSIZE));
    if blockInfo.outMode(1)

        startOutS=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name','startOutS');
        startOutS.SimulinkRate=dataRate;
        if VLDLEN==0
            pirelab.getWireComp(FFTImpl,dout_vld,startOutS);
        else
            fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities','+dsphdlsupport','+internal',...
            '@AbstractFFT','cgireml','startOutput.m'),'r');
            fcnBody=fread(fid,Inf,'char=>char')';
            fclose(fid);

            desc='startOutput';

            startOutComp=FFTImpl.addComponent2(...
            'kind','cgireml',...
            'Name','startOutput',...
            'InputSignals',dout_vld(1),...
            'OutputSignals',startOutS,...
            'ExternalSynchronousResetSignal',syncReset,...
            'EMLFileName','startOutput',...
            'EMLFileBody',fcnBody,...
            'EMLParams',{VLDLEN},...
            'EMLFlag_TreatInputIntsAsFixpt',true,...
            'EMLFlag_SaturateOnIntOverflow',false,...
            'EMLFlag_TreatInputBoolsAsUfix1',false,...
            'BlockComment',desc);

            startOutComp.runConcurrencyMaximizer(0);
        end

    end


    if blockInfo.outMode(2)

        endOutS=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name','endOutS');
        endOutS.SimulinkRate=dataRate;

        if VLDLEN==0
            pirelab.getWireComp(FFTImpl,dout_vld(1),endOutS);
        else
            fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
            '+dsphdlsupport','+internal','@AbstractFFT','cgireml','endOutput.m'),'r');
            fcnBody=fread(fid,Inf,'char=>char')';
            fclose(fid);

            desc='endOutput';

            endOutput=FFTImpl.addComponent2(...
            'kind','cgireml',...
            'Name','endOutput',...
            'InputSignals',dout_vld(1),...
            'OutputSignals',endOutS,...
            'ExternalSynchronousResetSignal',syncReset,...
            'EMLFileName','endOutput',...
            'EMLFileBody',fcnBody,...
            'EMLParams',{VLDLEN},...
            'EMLFlag_TreatInputIntsAsFixpt',true,...
            'EMLFlag_SaturateOnIntOverflow',false,...
            'EMLFlag_TreatInputBoolsAsUfix1',false,...
            'BlockComment',desc);

            endOutput.runConcurrencyMaximizer(0);
        end

    end





    if DATA_VECSIZE==1
        dout_cmplx=FFTImpl.addSignal2('Type',outsignals(1).Type,'Name','dout_cmplx');
        dout_cmplx.SimulinkRate=dataRate;
        pirelab.getRealImag2Complex(FFTImpl,[dout_re,dout_im],dout_cmplx);
        pirelab.getWireComp(FFTImpl,dout_cmplx,outsignals(1));
    else
        for inIndex=1:DATA_VECSIZE
            dout_cmplx(inIndex)=FFTImpl.addSignal2('Type',outsignals(1).Type.BaseType,'Name',['dout_cmplx_',int2str(inIndex)]);
            dout_cmplx(inIndex).SimulinkRate=dataRate;
            pirelab.getRealImag2Complex(FFTImpl,[dout_re(inIndex),dout_im(inIndex)],dout_cmplx(inIndex));
        end
        pirelab.getMuxComp(FFTImpl,dout_cmplx,outsignals(1));
    end

    if blockInfo.outMode(1)&&blockInfo.outMode(2)
        pirelab.getWireComp(FFTImpl,startOutS,outsignals(2));
        pirelab.getWireComp(FFTImpl,endOutS,outsignals(3));
        pirelab.getWireComp(FFTImpl,dout_vld,outsignals(4));
        pirelab.getWireComp(FFTImpl,rdy,outsignals(5));
    elseif blockInfo.outMode(1)
        pirelab.getWireComp(FFTImpl,startOutS,outsignals(2));
        pirelab.getWireComp(FFTImpl,dout_vld,outsignals(3));
        pirelab.getWireComp(FFTImpl,rdy,outsignals(4));
    elseif blockInfo.outMode(2)
        pirelab.getWireComp(FFTImpl,endOutS,outsignals(2));
        pirelab.getWireComp(FFTImpl,dout_vld,outsignals(3));
        pirelab.getWireComp(FFTImpl,rdy,outsignals(4));
    else
        pirelab.getWireComp(FFTImpl,dout_vld,outsignals(2));
        pirelab.getWireComp(FFTImpl,rdy,outsignals(3));
    end












