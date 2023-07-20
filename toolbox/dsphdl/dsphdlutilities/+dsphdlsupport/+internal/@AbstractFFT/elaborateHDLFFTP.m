function elaborateHDLFFTP(this,FFTImpl,blockInfo)








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
        softReset=insignals(3);
        softReset.SimulinkRate=dataRate;
    else
        softReset=FFTImpl.addSignal2('Type',pir_boolean_t,'Name','softReset');
        softReset.SimulinkRate=dataRate;
        if blockInfo.inResetSS


            softReset.setSynthResetInsideResetSS;

            blockInfo.inMode(2)=true;
        else


            pirelab.getConstComp(FFTImpl,softReset,false);
        end
    end



    if strcmpi(blockInfo.Architecture,'Burst Radix 2')
        ready=FFTImpl.addSignal2('Type',pir_boolean_t,'Name','ready');
        ready.SimulinkRate=insignals(1).SimulinkRate;


        pirelab.getLogicComp(FFTImpl,softReset,ready,'not');
        pirelab.getUnitDelayComp(FFTImpl,ready,outsignals(end),'',1);
    end

    DATA_SIGN=dataInType.issigned;
    DATA_WORDLENGTH=dataInType.wordsize;
    DATA_FRACTIONLENGTH=dataInType.binarypoint;
    DATA_VECSIZE=dataInType.dims;
    DATA_CMPLX=dataInType.iscomplex;
    BITREVERSEDINPUT=blockInfo.BitReversedInput;

    blockInfo.InputDataIsReal=~DATA_CMPLX;
    if DATA_SIGN
        din_type=pir_fixpt_t(1,DATA_WORDLENGTH,DATA_FRACTIONLENGTH);
    else
        din_type=pir_fixpt_t(1,DATA_WORDLENGTH+1,DATA_FRACTIONLENGTH);
        DATA_WORDLENGTH=DATA_WORDLENGTH+1;
    end

    FFTLENGTH=blockInfo.FFTLength;




    TWDL_WORDLENGTH=DATA_WORDLENGTH;
    TWDL_FRACTIONLENGTH=-(DATA_WORDLENGTH-2);
    blockInfo.TWDL_WORDLENGTH=TWDL_WORDLENGTH;
    blockInfo.TWDL_FRACTIONLENGTH=TWDL_FRACTIONLENGTH;




    for loop=1:DATA_VECSIZE
        din_re(1,loop)=FFTImpl.addSignal2('Type',din_type,'Name',['din_',int2str(loop),'_re']);
        din_re(1,loop).SimulinkRate=dataRate;
        din_im(1,loop)=FFTImpl.addSignal2('Type',din_type,'Name',['din_',int2str(loop),'_im']);
        din_im(1,loop).SimulinkRate=dataRate;

        dataIn_cast(loop)=FFTImpl.addSignal2('Type',pir_complex_t(pir_sfixpt_t(DATA_WORDLENGTH,DATA_FRACTIONLENGTH)),'Name',['dataIn_',int2str(loop),'_cast']);%#ok<*AGROW>
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




    TOTALSTAGES=floor(log2(FFTLENGTH)/2);
    notPowerOf4=(logical(rem(TOTALSTAGES,log2(FFTLENGTH)/2)));

    dOutType=pir_sfixpt_t(DATA_WORDLENGTH+(~blockInfo.Normalize)*blockInfo.BitGrowthVector(1),DATA_FRACTIONLENGTH);

    if~BITREVERSEDINPUT


        MEMSIZE=floor(double(FFTLENGTH)/double(2*DATA_VECSIZE));
        iter=1;
        for R22Stage=1:2:2*TOTALSTAGES


            R2Stage=R22Stage;
            BITGROWTH=(~blockInfo.Normalize)*blockInfo.BitGrowthVector(R2Stage);
            DATA_WORDLENGTH=DATA_WORDLENGTH+BITGROWTH;


            if MEMSIZE>0

                twdl_rd=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['twdl_',int2str(R2Stage),'_rd']);%#ok<*AGROW>
                twdl_rd.SimulinkRate=dataRate;

                rdEnb=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['rd_',int2str(R2Stage),'_Enb']);%#ok<*AGROW>
                rdEnb.SimulinkRate=dataRate;procEnb=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['proc_',int2str(R2Stage),'_enb']);%#ok<*AGROW>
                procEnb.SimulinkRate=dataRate;
                pirelab.getWireComp(FFTImpl,procEnb,twdl_rd);
                multiply_J=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['multiply_',int2str(R2Stage),'_J']);%#ok<*AGROW>
                multiply_J.SimulinkRate=dataRate;
                din_vld_dly=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['din_',int2str(R2Stage),'_vld_dly']);%#ok<*AGROW>
                din_vld_dly.SimulinkRate=dataRate;
                pirelab.getIntDelayEnabledResettableComp(FFTImpl,din_vld,din_vld_dly,'',softReset,3);
                din_dly_type=pir_sfixpt_t(din_re(1).Type.WordLength,din_re(1).Type.FractionLength);
                if MEMSIZE>1
                    rdAddr=FFTImpl.addSignal2('Type',pir_fixpt_t(0,log2(MEMSIZE),0),'Name',['rd_',int2str(R2Stage),'_Addr']);%#ok<*AGROW>
                    rdAddr.SimulinkRate=dataRate;
                elseif MEMSIZE==1
                    rdAddr=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['rd_',int2str(R2Stage),'_Addr']);%#ok<*AGROW>
                    rdAddr.SimulinkRate=dataRate;
                end
                for inIndex=1:DATA_VECSIZE

                    twdl_re(inIndex)=FFTImpl.addSignal2('Type',pir_sfixpt_t(TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH),'Name',['twdl_',int2str(R2Stage),'_',int2str(inIndex),'_re']);%#ok<*AGROW>
                    twdl_re(inIndex).SimulinkRate=dataRate;
                    twdl_im(inIndex)=FFTImpl.addSignal2('Type',pir_sfixpt_t(TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH),'Name',['twdl_',int2str(R2Stage),'_',int2str(inIndex),'_im']);%#ok<*AGROW>
                    twdl_im(inIndex).SimulinkRate=dataRate;
                    twdl_vld(inIndex)=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['twdl_',int2str(R2Stage),'_',int2str(inIndex),'_vld']);%#ok<*AGROW>
                    twdl_vld(inIndex).SimulinkRate=dataRate;
                    if R2Stage==1
                        pirelab.getConstComp(FFTImpl,twdl_re(inIndex),1);
                        pirelab.getConstComp(FFTImpl,twdl_im(inIndex),0);
                        pirelab.getIntDelayEnabledResettableComp(FFTImpl,din_vld,twdl_vld(inIndex),'',softReset,3);
                    else

                        twdlROM=this.elabRADIX22FFT_TWDL(FFTImpl,blockInfo,dataRate,R2Stage,inIndex,DATA_VECSIZE,BITREVERSEDINPUT,0,...
                        din_vld,softReset,...
                        twdl_re(inIndex),twdl_im(inIndex),twdl_vld(inIndex));
                        pirelab.instantiateNetwork(FFTImpl,twdlROM,[din_vld,softReset],...
                        [twdl_re(inIndex),twdl_im(inIndex),twdl_vld(inIndex)],...
                        ['twdlROM','_',int2str(R2Stage),'_',int2str(inIndex)]);
                    end

                    din_re_dly(inIndex)=FFTImpl.addSignal2('Type',din_dly_type,'Name',['din_',int2str(R2Stage),'_',int2str(inIndex),'_re_dly']);%#ok<*AGROW>
                    din_re_dly(inIndex).SimulinkRate=dataRate;
                    din_im_dly(inIndex)=FFTImpl.addSignal2('Type',din_dly_type,'Name',['din_',int2str(R2Stage),'_',int2str(inIndex),'_im_dly']);%#ok<*AGROW>
                    din_im_dly(inIndex).SimulinkRate=dataRate;
                    pirelab.getIntDelayEnabledResettableComp(FFTImpl,din_re(inIndex),din_re_dly(inIndex),'',softReset,3);
                    pirelab.getIntDelayEnabledResettableComp(FFTImpl,din_im(inIndex),din_im_dly(inIndex),'',softReset,3);
                    dout_re(inIndex)=FFTImpl.addSignal2('Type',dOutType,'Name',['dout_',int2str(R2Stage),'_',int2str(inIndex),'_re']);%#ok<*AGROW>
                    dout_re(inIndex).SimulinkRate=dataRate;
                    dout_im(inIndex)=FFTImpl.addSignal2('Type',dOutType,'Name',['dout_',int2str(R2Stage),'_',int2str(inIndex),'_im']);%#ok<*AGROW>
                    dout_im(inIndex).SimulinkRate=dataRate;
                    dout_vld(inIndex)=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['dout_',int2str(R2Stage),'_',int2str(inIndex),'_vld']);%#ok<*AGROW>
                    dout_vld(inIndex).SimulinkRate=dataRate;
                    dinXTwdl_vld(inIndex)=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['dinXTwdl_',int2str(R2Stage),'_',int2str(inIndex),'_vld']);%#ok<*AGROW>
                    dinXTwdl_vld(inIndex).SimulinkRate=dataRate;

                    SDF1=this.elabRADIX22FFT_SDF1(FFTImpl,blockInfo,R2Stage,MEMSIZE,dataRate,BITREVERSEDINPUT,...
                    DATA_WORDLENGTH,DATA_FRACTIONLENGTH,TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH,~BITGROWTH,...
                    din_re_dly(inIndex),din_im_dly(inIndex),din_vld_dly,rdAddr,rdEnb,...
                    twdl_re(inIndex),twdl_im(inIndex),twdl_vld(inIndex),...
                    procEnb,softReset,...
                    dout_re(inIndex),dout_im(inIndex),dout_vld(inIndex),dinXTwdl_vld(inIndex));
                    pirelab.instantiateNetwork(FFTImpl,SDF1,[din_re_dly(inIndex),din_im_dly(inIndex),din_vld_dly,rdAddr,rdEnb,...
                    twdl_re(inIndex),twdl_im(inIndex),twdl_vld(inIndex),procEnb,softReset],...
                    [dout_re(inIndex),dout_im(inIndex),dout_vld(inIndex),dinXTwdl_vld(inIndex)],...
                    ['SDF1','_',int2str(R2Stage),'_',int2str(inIndex)]);

                end

                CTRLRX2=this.elabRADIX22FFT_CTRL(FFTImpl,dataRate,R2Stage,blockInfo,MEMSIZE,BITREVERSEDINPUT,...
                dinXTwdl_vld(1),dinXTwdl_vld(1),softReset,...
                rdAddr,rdEnb,procEnb,multiply_J);
                pirelab.instantiateNetwork(FFTImpl,CTRLRX2,[dinXTwdl_vld(1),dinXTwdl_vld(1),softReset],...
                [rdAddr,rdEnb,procEnb,multiply_J],...
                ['CTRL1','_',int2str(R2Stage),'_',int2str(inIndex)]);
            else

                for inIndex=1:2:(DATA_VECSIZE)



                    twdlXdin_re(inIndex)=FFTImpl.addSignal2('Type',dOutType,'Name',['twdlXdin_',int2str(inIndex),'_re']);%#ok<*AGROW>
                    twdlXdin_re(inIndex).SimulinkRate=dataRate;
                    twdlXdin_im(inIndex)=FFTImpl.addSignal2('Type',dOutType,'Name',['twdlXdin_',int2str(inIndex),'_im']);%#ok<*AGROW>
                    twdlXdin_im(inIndex).SimulinkRate=dataRate;
                    twdlXdin_re(inIndex+1)=FFTImpl.addSignal2('Type',dOutType,'Name',['twdlXdin_',int2str(inIndex+1),'_re']);%#ok<*AGROW>
                    twdlXdin_re(inIndex+1).SimulinkRate=dataRate;
                    twdlXdin_im(inIndex+1)=FFTImpl.addSignal2('Type',dOutType,'Name',['twdlXdin_',int2str(inIndex+1),'_im']);%#ok<*AGROW>
                    twdlXdin_im(inIndex+1).SimulinkRate=dataRate;
                    twdlXdin_vld(inIndex)=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['twdlXdin_',int2str(inIndex),'_vld']);%#ok<*AGROW>
                    twdlXdin_vld(inIndex).SimulinkRate=dataRate;
                    if R2Stage==1
                        pirelab.getDTCComp(FFTImpl,din_re(inIndex),twdlXdin_re(inIndex));
                        pirelab.getDTCComp(FFTImpl,din_im(inIndex),twdlXdin_im(inIndex));
                        pirelab.getDTCComp(FFTImpl,din_re(inIndex+1),twdlXdin_re(inIndex+1));
                        pirelab.getDTCComp(FFTImpl,din_im(inIndex+1),twdlXdin_im(inIndex+1));
                        pirelab.getDTCComp(FFTImpl,din_vld,twdlXdin_vld(inIndex));
                    else
                        twdl_re(inIndex)=FFTImpl.addSignal2('Type',pir_sfixpt_t(TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH),'Name',['twdl_',int2str(R2Stage),'_',int2str(inIndex),'_re']);%#ok<*AGROW>
                        twdl_re(inIndex).SimulinkRate=dataRate;
                        twdl_im(inIndex)=FFTImpl.addSignal2('Type',pir_sfixpt_t(TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH),'Name',['twdl_',int2str(R2Stage),'_',int2str(inIndex),'_im']);%#ok<*AGROW>
                        twdl_im(inIndex).SimulinkRate=dataRate;
                        twdl_re(inIndex+1)=FFTImpl.addSignal2('Type',pir_sfixpt_t(TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH),'Name',['twdl_',int2str(R2Stage),'_',int2str(inIndex+1),'_re']);%#ok<*AGROW>
                        twdl_re(inIndex+1).SimulinkRate=dataRate;
                        twdl_im(inIndex+1)=FFTImpl.addSignal2('Type',pir_sfixpt_t(TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH),'Name',['twdl_',int2str(R2Stage),'_',int2str(inIndex+1),'_im']);%#ok<*AGROW>
                        twdl_im(inIndex+1).SimulinkRate=dataRate;
                        twdl_vld(inIndex)=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['twdl_',int2str(R2Stage),'_',int2str(inIndex),'_vld']);%#ok<*AGROW>
                        twdl_vld(inIndex).SimulinkRate=dataRate;
                        twdl_vld(inIndex+1)=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['twdl_',int2str(R2Stage),'_',int2str(inIndex+1),'_vld']);%#ok<*AGROW>
                        twdl_vld(inIndex+1).SimulinkRate=dataRate;
                        needMultiplier=requireMultiplication(inIndex,2*TOTALSTAGES-R22Stage,notPowerOf4);
                        if needMultiplier
                            twdlROM1=this.elabRADIX22FFT_TWDL(FFTImpl,blockInfo,dataRate,R2Stage,inIndex,DATA_VECSIZE,BITREVERSEDINPUT,0,...
                            din_vld,softReset,...
                            twdl_re(inIndex),twdl_im(inIndex),twdl_vld(inIndex));
                            pirelab.instantiateNetwork(FFTImpl,twdlROM1,[din_vld,softReset],...
                            [twdl_re(inIndex),twdl_im(inIndex),twdl_vld(inIndex)],...
                            ['twdlROM','_',int2str(R2Stage),'_',int2str(inIndex)]);
                        else
                            pirelab.getConstComp(FFTImpl,twdl_re(inIndex),1);
                            pirelab.getConstComp(FFTImpl,twdl_im(inIndex),0);
                            pirelab.getConstComp(FFTImpl,twdl_vld(inIndex),1);
                        end
                        twdlROM2=this.elabRADIX22FFT_TWDL(FFTImpl,blockInfo,dataRate,R2Stage,inIndex+1,DATA_VECSIZE,BITREVERSEDINPUT,0,...
                        din_vld,softReset,...
                        twdl_re(inIndex+1),twdl_im(inIndex+1),twdl_vld(inIndex+1));
                        pirelab.instantiateNetwork(FFTImpl,twdlROM2,[din_vld,softReset],...
                        [twdl_re(inIndex+1),twdl_im(inIndex+1),twdl_vld(inIndex+1)],...
                        ['twdlROM','_',int2str(R2Stage),'_',int2str(inIndex+1)]);
                        twdlXdin_re(inIndex)=FFTImpl.addSignal2('Type',dOutType,'Name',['twdlXdin_',int2str(inIndex),'_re']);%#ok<*AGROW>
                        twdlXdin_re(inIndex).SimulinkRate=dataRate;
                        twdlXdin_im(inIndex)=FFTImpl.addSignal2('Type',dOutType,'Name',['twdlXdin_',int2str(inIndex),'_im']);%#ok<*AGROW>
                        twdlXdin_im(inIndex).SimulinkRate=dataRate;
                        twdlXdin_re(inIndex+1)=FFTImpl.addSignal2('Type',dOutType,'Name',['twdlXdin_',int2str(inIndex+1),'_re']);%#ok<*AGROW>
                        twdlXdin_re(inIndex+1).SimulinkRate=dataRate;
                        twdlXdin_im(inIndex+1)=FFTImpl.addSignal2('Type',dOutType,'Name',['twdlXdin_',int2str(inIndex+1),'_im']);%#ok<*AGROW>
                        twdlXdin_im(inIndex+1).SimulinkRate=dataRate;
                        twdlXdin_vld(inIndex)=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['twdlXdin_',int2str(inIndex),'_vld']);%#ok<*AGROW>
                        twdlXdin_vld(inIndex).SimulinkRate=dataRate;
                        multByOne1=true;multByOne2=true;
                        TWDLMULT=this.elabTWDLMULT_SDNF1(FFTImpl,blockInfo,R2Stage,dataRate,needMultiplier,BITREVERSEDINPUT,multByOne1,multByOne2,...
                        DATA_WORDLENGTH,DATA_FRACTIONLENGTH,TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH,...
                        din_re(inIndex),din_im(inIndex),din_re(inIndex+1),din_im(inIndex+1),din_vld,...
                        twdl_re(inIndex),twdl_im(inIndex),twdl_re(inIndex+1),twdl_im(inIndex+1),twdl_vld(inIndex+1),softReset,...
                        twdlXdin_re(inIndex),twdlXdin_im(inIndex),twdlXdin_re(inIndex+1),twdlXdin_im(inIndex+1),twdlXdin_vld(inIndex));
                        pirelab.instantiateNetwork(FFTImpl,TWDLMULT,[din_re(inIndex),din_im(inIndex),din_re(inIndex+1),din_im(inIndex+1),din_vld,...
                        twdl_re(inIndex),twdl_im(inIndex),twdl_re(inIndex+1),twdl_im(inIndex+1),twdl_vld(inIndex+1),softReset],...
                        [twdlXdin_re(inIndex),twdlXdin_im(inIndex),twdlXdin_re(inIndex+1),twdlXdin_im(inIndex+1),twdlXdin_vld(inIndex)],...
                        ['TWDLMULT_SDNF1','_',int2str(R2Stage),'_',int2str(inIndex)]);
                    end
                end


                twdlXdin_re=reroute(twdlXdin_re,iter);
                twdlXdin_im=reroute(twdlXdin_im,iter);

                for inIndex=1:2:(DATA_VECSIZE)

                    dout_re(inIndex)=FFTImpl.addSignal2('Type',dOutType,'Name',['dout_',int2str(inIndex),'_re']);%#ok<*AGROW>
                    dout_re(inIndex).SimulinkRate=dataRate;
                    dout_im(inIndex)=FFTImpl.addSignal2('Type',dOutType,'Name',['dout_',int2str(inIndex),'_im']);%#ok<*AGROW>
                    dout_im(inIndex).SimulinkRate=dataRate;
                    dout_re(inIndex+1)=FFTImpl.addSignal2('Type',dOutType,'Name',['dout_',int2str(inIndex+1),'_re']);%#ok<*AGROW>
                    dout_re(inIndex+1).SimulinkRate=dataRate;
                    dout_im(inIndex+1)=FFTImpl.addSignal2('Type',dOutType,'Name',['dout_',int2str(inIndex+1),'_im']);%#ok<*AGROW>
                    dout_im(inIndex+1).SimulinkRate=dataRate;
                    dout_vld(inIndex)=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['dout_',int2str(inIndex),'_vld']);%#ok<*AGROW>
                    dout_vld(inIndex).SimulinkRate=dataRate;

                    SDNF1=this.elabRADIX22FFT_SDNF1(FFTImpl,blockInfo,R2Stage,dataRate,...
                    DATA_WORDLENGTH,DATA_FRACTIONLENGTH,~BITGROWTH,...
                    twdlXdin_re(inIndex),twdlXdin_im(inIndex),twdlXdin_re(inIndex+1),twdlXdin_im(inIndex+1),twdlXdin_vld(1),softReset,...
                    dout_re(inIndex),dout_im(inIndex),dout_re(inIndex+1),dout_im(inIndex+1),dout_vld(inIndex));
                    pirelab.instantiateNetwork(FFTImpl,SDNF1,...
                    [twdlXdin_re(inIndex),twdlXdin_im(inIndex),twdlXdin_re(inIndex+1),twdlXdin_im(inIndex+1),twdlXdin_vld(1),softReset],...
                    [dout_re(inIndex),dout_im(inIndex),dout_re(inIndex+1),dout_im(inIndex+1),dout_vld(inIndex)],...
                    ['SDNF1','_',int2str(R2Stage),'_',int2str(inIndex)]);

                end

                for loop=1:log2(length(dout_re))-iter
                    dout_re=reroute(dout_re,iter);
                    dout_im=reroute(dout_im,iter);
                end
                iter=iter+1;
            end


            din_vld=dout_vld(1);
            for inIndex=1:DATA_VECSIZE
                din_re(inIndex)=dout_re(inIndex);
                din_im(inIndex)=dout_im(inIndex);
            end

            MEMSIZE=floor(double(MEMSIZE)/2);



            R2Stage=R22Stage+1;
            BITGROWTH=(~blockInfo.Normalize)*blockInfo.BitGrowthVector(R2Stage);
            DATA_WORDLENGTH=DATA_WORDLENGTH+BITGROWTH;
            dOutType=pir_sfixpt_t(dOutType.WordLength+(~blockInfo.Normalize)*blockInfo.BitGrowthVector(R2Stage),DATA_FRACTIONLENGTH);


            if MEMSIZE>0

                rdEnb=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['rd_',int2str(R2Stage),'_Enb']);%#ok<*AGROW>
                rdEnb.SimulinkRate=dataRate;
                if MEMSIZE>1
                    rdAddr=FFTImpl.addSignal2('Type',pir_fixpt_t(0,log2(MEMSIZE),0),'Name',['rd_',int2str(R2Stage),'_Addr']);%#ok<*AGROW>
                    rdAddr.SimulinkRate=dataRate;
                elseif MEMSIZE==1
                    rdAddr=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['rd_',int2str(R2Stage),'_Addr']);%#ok<*AGROW>
                    rdAddr.SimulinkRate=dataRate;
                end
                procEnb=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['proc_',int2str(R2Stage),'_enb']);%#ok<*AGROW>
                procEnb.SimulinkRate=dataRate;
                dinXTwdl_vld=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['dinXTwdl_',int2str(R2Stage),'_vld']);%#ok<*AGROW>
                dinXTwdl_vld.SimulinkRate=dataRate;

                multiply_J=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['multiply_',int2str(R2Stage),'_J']);%#ok<*AGROW>
                multiply_J.SimulinkRate=dataRate;
                ROTATION=true;
                for inIndex=1:DATA_VECSIZE
                    dout_re(inIndex)=FFTImpl.addSignal2('Type',dOutType,'Name',['dout_',int2str(R2Stage),'_',int2str(inIndex),'_re']);%#ok<*AGROW>
                    dout_re(inIndex).SimulinkRate=dataRate;
                    dout_im(inIndex)=FFTImpl.addSignal2('Type',dOutType,'Name',['dout_',int2str(R2Stage),'_',int2str(inIndex),'_im']);%#ok<*AGROW>
                    dout_im(inIndex).SimulinkRate=dataRate;
                    dout_vld(inIndex)=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['dout_',int2str(R2Stage),'_',int2str(inIndex),'_vld']);%#ok<*AGROW>
                    dout_vld(inIndex).SimulinkRate=dataRate;
                    dinXTwdl_vld(inIndex)=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['dinXTwdl_',int2str(R2Stage),'_',int2str(inIndex),'_vld']);%#ok<*AGROW>
                    dinXTwdl_vld(inIndex).SimulinkRate=dataRate;

                    RX2=this.elabRADIX22FFT_SDF2(FFTImpl,blockInfo,R2Stage,MEMSIZE,dataRate,...
                    DATA_WORDLENGTH,DATA_FRACTIONLENGTH,~BITGROWTH,ROTATION,...
                    din_re(inIndex),din_im(inIndex),din_vld,rdAddr,rdEnb,...
                    procEnb,multiply_J,softReset,...
                    dout_re(inIndex),dout_im(inIndex),dout_vld(inIndex),dinXTwdl_vld(inIndex));
                    pirelab.instantiateNetwork(FFTImpl,RX2,[din_re(inIndex),din_im(inIndex),din_vld,rdAddr,rdEnb,...
                    procEnb,multiply_J,softReset],...
                    [dout_re(inIndex),dout_im(inIndex),dout_vld(inIndex),dinXTwdl_vld(inIndex)],...
                    ['SDF2','_',int2str(R2Stage),'_',int2str(inIndex)]);
                end


                CTRLRX2=this.elabRADIX22FFT_CTRL(FFTImpl,dataRate,R2Stage,blockInfo,MEMSIZE,BITREVERSEDINPUT,...
                din_vld,dinXTwdl_vld(1),softReset,...
                rdAddr,rdEnb,procEnb,multiply_J);
                pirelab.instantiateNetwork(FFTImpl,CTRLRX2,[din_vld,dinXTwdl_vld(1),softReset],...
                [rdAddr,rdEnb,procEnb,multiply_J],...
                ['CTRL2','_',int2str(R2Stage),'_',int2str(inIndex)]);
            else

                din_re=reroute(din_re,iter);
                din_im=reroute(din_im,iter);
                if needCtrl(DATA_VECSIZE,FFTLENGTH,R2Stage,MEMSIZE,BITREVERSEDINPUT)

                    rotate(1)=FFTImpl.addSignal2('Type',pir_ufixpt_t(1,0),'Name',['rotate_',int2str(inIndex)]);%#ok<*AGROW>
                    rotate(1).SimulinkRate=dataRate;
                    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
                    '+dsphdlsupport','+internal','@AbstractFFT','cgireml','CTRL_SDNF2.m'),'r');
                    fcnBody=fread(fid,Inf,'char=>char')';
                    fclose(fid);

                    desc='CTRL_SDNF2';

                    CTRL_SDNF2=FFTImpl.addComponent2(...
                    'kind','cgireml',...
                    'Name','CTRL_SDNF2',...
                    'InputSignals',din_vld,...
                    'OutputSignals',rotate(1),...
                    'ExternalSynchronousResetSignal',softReset,...
                    'EMLFileName','CTRL_SDNF2',...
                    'EMLFileBody',fcnBody,...
                    'EMLParams',{},...
                    'EMLFlag_TreatInputIntsAsFixpt',true,...
                    'EMLFlag_SaturateOnIntOverflow',false,...
                    'EMLFlag_TreatInputBoolsAsUfix1',false,...
                    'BlockComment',desc);

                    CTRL_SDNF2.runConcurrencyMaximizer(0);
                    for inIndex=1:2:(DATA_VECSIZE)

                        dout_re(inIndex)=FFTImpl.addSignal2('Type',dOutType,'Name',['dout_',int2str(inIndex),'_re']);%#ok<*AGROW>
                        dout_re(inIndex).SimulinkRate=dataRate;
                        dout_im(inIndex)=FFTImpl.addSignal2('Type',dOutType,'Name',['dout_',int2str(inIndex),'_im']);%#ok<*AGROW>
                        dout_im(inIndex).SimulinkRate=dataRate;
                        dout_re(inIndex+1)=FFTImpl.addSignal2('Type',dOutType,'Name',['dout_',int2str(inIndex+1),'_re']);%#ok<*AGROW>
                        dout_re(inIndex+1).SimulinkRate=dataRate;
                        dout_im(inIndex+1)=FFTImpl.addSignal2('Type',dOutType,'Name',['dout_',int2str(inIndex+1),'_im']);%#ok<*AGROW>
                        dout_im(inIndex+1).SimulinkRate=dataRate;
                        dout_vld(inIndex)=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['dout_',int2str(R2Stage),'_vld']);%#ok<*AGROW>
                        dout_vld(inIndex).SimulinkRate=dataRate;

                        SDNF2=this.elabRADIX22FFT_SDNF2(FFTImpl,blockInfo,R2Stage,dataRate,...
                        DATA_WORDLENGTH,DATA_FRACTIONLENGTH,~BITGROWTH,...
                        rotate(1),din_re(inIndex),din_im(inIndex),din_re(inIndex+1),din_im(inIndex+1),din_vld,softReset,...
                        dout_re(inIndex),dout_im(inIndex),dout_re(inIndex+1),dout_im(inIndex+1),dout_vld(inIndex));

                        pirelab.instantiateNetwork(FFTImpl,SDNF2,[rotate(1),din_re(inIndex),din_im(inIndex),din_re(inIndex+1),din_im(inIndex+1),din_vld,softReset],...
                        [dout_re(inIndex),dout_im(inIndex),dout_re(inIndex+1),dout_im(inIndex+1),dout_vld(inIndex)],...
                        ['SDNF2','_',int2str(R2Stage),'_',int2str(inIndex)]);
                    end
                else

                    ROTATE_VALUE=JMultiplication(FFTLENGTH,BITREVERSEDINPUT,R2Stage,DATA_VECSIZE);
                    for inIndex=1:2:(DATA_VECSIZE)
                        rotate(inIndex)=FFTImpl.addSignal2('Type',pir_ufixpt_t(1,0),'Name',['rotate_',int2str(inIndex)]);%#ok<*AGROW>
                        rotate(inIndex).SimulinkRate=dataRate;
                        pirelab.getConstComp(FFTImpl,rotate(inIndex),ROTATE_VALUE(ceil(inIndex/2)));

                        dout_re(inIndex)=FFTImpl.addSignal2('Type',dOutType,'Name',['dout_',int2str(inIndex),'_re']);%#ok<*AGROW>
                        dout_re(inIndex).SimulinkRate=dataRate;
                        dout_im(inIndex)=FFTImpl.addSignal2('Type',dOutType,'Name',['dout_',int2str(inIndex),'_im']);%#ok<*AGROW>
                        dout_im(inIndex).SimulinkRate=dataRate;
                        dout_re(inIndex+1)=FFTImpl.addSignal2('Type',dOutType,'Name',['dout_',int2str(inIndex+1),'_re']);%#ok<*AGROW>
                        dout_re(inIndex+1).SimulinkRate=dataRate;
                        dout_im(inIndex+1)=FFTImpl.addSignal2('Type',dOutType,'Name',['dout_',int2str(inIndex+1),'_im']);%#ok<*AGROW>
                        dout_im(inIndex+1).SimulinkRate=dataRate;
                        dout_vld(inIndex)=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['dout_',int2str(R2Stage),'_vld']);%#ok<*AGROW>
                        dout_vld(inIndex).SimulinkRate=dataRate;

                        SDNF2=this.elabRADIX22FFT_SDNF2(FFTImpl,blockInfo,R2Stage,dataRate,...
                        DATA_WORDLENGTH,DATA_FRACTIONLENGTH,~BITGROWTH,...
                        rotate(inIndex),din_re(inIndex),din_im(inIndex),din_re(inIndex+1),din_im(inIndex+1),din_vld,softReset,...
                        dout_re(inIndex),dout_im(inIndex),dout_re(inIndex+1),dout_im(inIndex+1),dout_vld(inIndex));

                        pirelab.instantiateNetwork(FFTImpl,SDNF2,[rotate(inIndex),din_re(inIndex),din_im(inIndex),din_re(inIndex+1),din_im(inIndex+1),din_vld,softReset],...
                        [dout_re(inIndex),dout_im(inIndex),dout_re(inIndex+1),dout_im(inIndex+1),dout_vld(inIndex)],...
                        ['SDNF2','_',int2str(R2Stage),'_',int2str(inIndex)]);
                    end
                end
                for loop=1:log2(length(dout_re))-iter
                    dout_re=reroute(dout_re,iter);
                    dout_im=reroute(dout_im,iter);
                end
                iter=iter+1;

            end

            din_vld=dout_vld(1);
            for inIndex=1:DATA_VECSIZE
                din_re(inIndex)=dout_re(inIndex);
                din_im(inIndex)=dout_im(inIndex);
            end

            MEMSIZE=floor(double(MEMSIZE)/2);

            dOutType=pir_sfixpt_t(dOutType.WordLength+(~blockInfo.Normalize)*blockInfo.BitGrowthVector(R2Stage),DATA_FRACTIONLENGTH);

        end
    else






        MEMSIZE=1-log2(double(DATA_VECSIZE));
        iter=log2(double(DATA_VECSIZE));
        for R22Stage=1:2:2*TOTALSTAGES


            R2Stage=R22Stage;
            BITGROWTH=(~blockInfo.Normalize)*blockInfo.BitGrowthVector(R2Stage);
            DATA_WORDLENGTH=DATA_WORDLENGTH+BITGROWTH;

            if MEMSIZE>0

                twdl_rd=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['twdl_',int2str(R2Stage),'_rd']);%#ok<*AGROW>
                twdl_rd.SimulinkRate=dataRate;

                rdEnb=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['rd_',int2str(R2Stage),'_Enb']);%#ok<*AGROW>
                rdEnb.SimulinkRate=dataRate;
                procEnb=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['proc_',int2str(R2Stage),'_enb']);%#ok<*AGROW>
                procEnb.SimulinkRate=dataRate;
                pirelab.getWireComp(FFTImpl,procEnb,twdl_rd);
                multiply_J=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['multiply_',int2str(R2Stage),'_J']);%#ok<*AGROW>
                multiply_J.SimulinkRate=dataRate;
                din_vld_dly=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['din_',int2str(R2Stage),'_vld_dly']);%#ok<*AGROW>
                din_vld_dly.SimulinkRate=dataRate;
                pirelab.getIntDelayEnabledResettableComp(FFTImpl,din_vld,din_vld_dly,'',softReset,3);
                din_dly_type=pir_sfixpt_t(din_re(1).Type.WordLength,din_re(1).Type.FractionLength);
                if MEMSIZE>1
                    rdAddr=FFTImpl.addSignal2('Type',pir_fixpt_t(0,log2(MEMSIZE),0),'Name',['rd_',int2str(R2Stage),'_Addr']);%#ok<*AGROW>
                    rdAddr.SimulinkRate=dataRate;
                elseif MEMSIZE==1
                    rdAddr=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['rd_',int2str(R2Stage),'_Addr']);%#ok<*AGROW>
                    rdAddr.SimulinkRate=dataRate;
                end
                for inIndex=1:DATA_VECSIZE

                    twdl_re(inIndex)=FFTImpl.addSignal2('Type',pir_sfixpt_t(TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH),'Name',['twdl_',int2str(R2Stage),'_',int2str(inIndex),'_re']);%#ok<*AGROW>
                    twdl_re(inIndex).SimulinkRate=dataRate;
                    twdl_im(inIndex)=FFTImpl.addSignal2('Type',pir_sfixpt_t(TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH),'Name',['twdl_',int2str(R2Stage),'_',int2str(inIndex),'_im']);%#ok<*AGROW>
                    twdl_im(inIndex).SimulinkRate=dataRate;
                    twdl_vld(inIndex)=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['twdl_',int2str(R2Stage),'_',int2str(inIndex),'_vld']);%#ok<*AGROW>
                    twdl_vld(inIndex).SimulinkRate=dataRate;
                    if R2Stage==1
                        pirelab.getConstComp(FFTImpl,twdl_re(inIndex),1);
                        pirelab.getConstComp(FFTImpl,twdl_im(inIndex),0);
                        pirelab.getIntDelayEnabledResettableComp(FFTImpl,din_vld,twdl_vld(inIndex),'',softReset,3);
                    else

                        twdlROM=this.elabRADIX22FFT_TWDL(FFTImpl,blockInfo,dataRate,R2Stage,inIndex,DATA_VECSIZE,BITREVERSEDINPUT,0,...
                        din_vld,softReset,...
                        twdl_re(inIndex),twdl_im(inIndex),twdl_vld(inIndex));
                        pirelab.instantiateNetwork(FFTImpl,twdlROM,[din_vld,softReset],...
                        [twdl_re(inIndex),twdl_im(inIndex),twdl_vld(inIndex)],...
                        ['twdlROM','_',int2str(R2Stage),'_',int2str(inIndex)]);
                    end

                    din_re_dly(inIndex)=FFTImpl.addSignal2('Type',din_dly_type,'Name',['din_',int2str(R2Stage),'_',int2str(inIndex),'_re_dly']);%#ok<*AGROW>
                    din_re_dly(inIndex).SimulinkRate=dataRate;
                    din_im_dly(inIndex)=FFTImpl.addSignal2('Type',din_dly_type,'Name',['din_',int2str(R2Stage),'_',int2str(inIndex),'_im_dly']);%#ok<*AGROW>
                    din_im_dly(inIndex).SimulinkRate=dataRate;
                    pirelab.getIntDelayEnabledResettableComp(FFTImpl,din_re(inIndex),din_re_dly(inIndex),'',softReset,3);
                    pirelab.getIntDelayEnabledResettableComp(FFTImpl,din_im(inIndex),din_im_dly(inIndex),'',softReset,3);
                    dout_re(inIndex)=FFTImpl.addSignal2('Type',dOutType,'Name',['dout_',int2str(R2Stage),'_',int2str(inIndex),'_re']);%#ok<*AGROW>
                    dout_re(inIndex).SimulinkRate=dataRate;
                    dout_im(inIndex)=FFTImpl.addSignal2('Type',dOutType,'Name',['dout_',int2str(R2Stage),'_',int2str(inIndex),'_im']);%#ok<*AGROW>
                    dout_im(inIndex).SimulinkRate=dataRate;
                    dout_vld(inIndex)=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['dout_',int2str(R2Stage),'_',int2str(inIndex),'_vld']);%#ok<*AGROW>
                    dout_vld(inIndex).SimulinkRate=dataRate;
                    dinXTwdl_vld(inIndex)=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['dinXTwdl_',int2str(R2Stage),'_',int2str(inIndex),'_vld']);%#ok<*AGROW>
                    dinXTwdl_vld(inIndex).SimulinkRate=dataRate;

                    SDF1=this.elabRADIX22FFT_SDF1(FFTImpl,blockInfo,R2Stage,MEMSIZE,dataRate,BITREVERSEDINPUT,...
                    DATA_WORDLENGTH,DATA_FRACTIONLENGTH,TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH,~BITGROWTH,...
                    din_re_dly(inIndex),din_im_dly(inIndex),din_vld_dly,rdAddr,rdEnb,...
                    twdl_re(inIndex),twdl_im(inIndex),twdl_vld(inIndex),...
                    procEnb,softReset,...
                    dout_re(inIndex),dout_im(inIndex),dout_vld(inIndex),dinXTwdl_vld(inIndex));
                    pirelab.instantiateNetwork(FFTImpl,SDF1,[din_re_dly(inIndex),din_im_dly(inIndex),din_vld_dly,rdAddr,rdEnb,...
                    twdl_re(inIndex),twdl_im(inIndex),twdl_vld(inIndex),procEnb,softReset],...
                    [dout_re(inIndex),dout_im(inIndex),dout_vld(inIndex),dinXTwdl_vld(inIndex)],...
                    ['SDF1','_',int2str(R2Stage),'_',int2str(inIndex)]);

                end

                CTRLRX2=this.elabRADIX22FFT_CTRL(FFTImpl,dataRate,R2Stage,blockInfo,MEMSIZE,BITREVERSEDINPUT,...
                dinXTwdl_vld(1),dinXTwdl_vld(1),softReset,...
                rdAddr,rdEnb,procEnb,multiply_J);
                pirelab.instantiateNetwork(FFTImpl,CTRLRX2,[dinXTwdl_vld(1),dinXTwdl_vld(1),softReset],...
                [rdAddr,rdEnb,procEnb,multiply_J],...
                ['CTRL1','_',int2str(R2Stage),'_',int2str(inIndex)]);
                MEMSIZE=MEMSIZE*2;
            else

                for inIndex=1:2:(DATA_VECSIZE)



                    needMultiplier=requireMultiplication(inIndex,2*TOTALSTAGES-R22Stage,notPowerOf4);
                    twdlXdin_re(inIndex)=FFTImpl.addSignal2('Type',dOutType,'Name',['twdlXdin_',int2str(inIndex),'_re']);%#ok<*AGROW>
                    twdlXdin_re(inIndex).SimulinkRate=dataRate;
                    twdlXdin_im(inIndex)=FFTImpl.addSignal2('Type',dOutType,'Name',['twdlXdin_',int2str(inIndex),'_im']);%#ok<*AGROW>
                    twdlXdin_im(inIndex).SimulinkRate=dataRate;
                    twdlXdin_re(inIndex+1)=FFTImpl.addSignal2('Type',dOutType,'Name',['twdlXdin_',int2str(inIndex+1),'_re']);%#ok<*AGROW>
                    twdlXdin_re(inIndex+1).SimulinkRate=dataRate;
                    twdlXdin_im(inIndex+1)=FFTImpl.addSignal2('Type',dOutType,'Name',['twdlXdin_',int2str(inIndex+1),'_im']);%#ok<*AGROW>
                    twdlXdin_im(inIndex+1).SimulinkRate=dataRate;
                    twdlXdin_vld(inIndex)=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['twdlXdin_',int2str(inIndex),'_vld']);%#ok<*AGROW>
                    twdlXdin_vld(inIndex).SimulinkRate=dataRate;
                    if R2Stage==1
                        pirelab.getDTCComp(FFTImpl,din_re(inIndex),twdlXdin_re(inIndex));
                        pirelab.getDTCComp(FFTImpl,din_im(inIndex),twdlXdin_im(inIndex));
                        pirelab.getDTCComp(FFTImpl,din_re(inIndex+1),twdlXdin_re(inIndex+1));
                        pirelab.getDTCComp(FFTImpl,din_im(inIndex+1),twdlXdin_im(inIndex+1));
                        pirelab.getDTCComp(FFTImpl,din_vld,twdlXdin_vld(inIndex));
                    else
                        twdl_re(inIndex)=FFTImpl.addSignal2('Type',pir_sfixpt_t(TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH),'Name',['twdl_',int2str(R2Stage),'_',int2str(inIndex),'_re']);%#ok<*AGROW>
                        twdl_re(inIndex).SimulinkRate=dataRate;
                        twdl_im(inIndex)=FFTImpl.addSignal2('Type',pir_sfixpt_t(TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH),'Name',['twdl_',int2str(R2Stage),'_',int2str(inIndex),'_im']);%#ok<*AGROW>
                        twdl_im(inIndex).SimulinkRate=dataRate;
                        twdl_re(inIndex+1)=FFTImpl.addSignal2('Type',pir_sfixpt_t(TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH),'Name',['twdl_',int2str(R2Stage),'_',int2str(inIndex+1),'_re']);%#ok<*AGROW>
                        twdl_re(inIndex+1).SimulinkRate=dataRate;
                        twdl_im(inIndex+1)=FFTImpl.addSignal2('Type',pir_sfixpt_t(TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH),'Name',['twdl_',int2str(R2Stage),'_',int2str(inIndex+1),'_im']);%#ok<*AGROW>
                        twdl_im(inIndex+1).SimulinkRate=dataRate;
                        twdl_vld(inIndex)=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['twdl_',int2str(R2Stage),'_',int2str(inIndex),'_vld']);%#ok<*AGROW>
                        twdl_vld(inIndex).SimulinkRate=dataRate;
                        twdl_vld(inIndex+1)=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['twdl_',int2str(R2Stage),'_',int2str(inIndex+1),'_vld']);%#ok<*AGROW>
                        twdl_vld(inIndex+1).SimulinkRate=dataRate;
                        multByOne1=multByOne(R2Stage,DATA_VECSIZE,inIndex);
                        if multByOne1
                            pirelab.getConstComp(FFTImpl,twdl_re(inIndex),1);
                            pirelab.getConstComp(FFTImpl,twdl_im(inIndex),0);
                            pirelab.getConstComp(FFTImpl,twdl_vld(inIndex),1);
                        else
                            twdlROM1=this.elabRADIX22FFT_TWDL(FFTImpl,blockInfo,dataRate,R2Stage,inIndex,DATA_VECSIZE,BITREVERSEDINPUT,0,...
                            din_vld,softReset,...
                            twdl_re(inIndex),twdl_im(inIndex),twdl_vld(inIndex));
                            pirelab.instantiateNetwork(FFTImpl,twdlROM1,[din_vld,softReset],...
                            [twdl_re(inIndex),twdl_im(inIndex),twdl_vld(inIndex)],...
                            ['twdlROM','_',int2str(R2Stage),'_',int2str(inIndex)]);
                        end
                        multByOne2=multByOne(R2Stage,DATA_VECSIZE,inIndex+1);
                        if multByOne2
                            pirelab.getConstComp(FFTImpl,twdl_re(inIndex+1),1);
                            pirelab.getConstComp(FFTImpl,twdl_im(inIndex+1),0);
                            pirelab.getConstComp(FFTImpl,twdl_vld(inIndex+1),1);
                        else

                            twdlROM2=this.elabRADIX22FFT_TWDL(FFTImpl,blockInfo,dataRate,R2Stage,inIndex+1,DATA_VECSIZE,BITREVERSEDINPUT,0,...
                            din_vld,softReset,...
                            twdl_re(inIndex+1),twdl_im(inIndex+1),twdl_vld(inIndex+1));
                            pirelab.instantiateNetwork(FFTImpl,twdlROM2,[din_vld,softReset],...
                            [twdl_re(inIndex+1),twdl_im(inIndex+1),twdl_vld(inIndex+1)],...
                            ['twdlROM','_',int2str(R2Stage),'_',int2str(inIndex+1)]);
                        end
                        twdlXdin_re(inIndex)=FFTImpl.addSignal2('Type',dOutType,'Name',['twdlXdin_',int2str(inIndex),'_re']);%#ok<*AGROW>
                        twdlXdin_re(inIndex).SimulinkRate=dataRate;
                        twdlXdin_im(inIndex)=FFTImpl.addSignal2('Type',dOutType,'Name',['twdlXdin_',int2str(inIndex),'_im']);%#ok<*AGROW>
                        twdlXdin_im(inIndex).SimulinkRate=dataRate;
                        twdlXdin_re(inIndex+1)=FFTImpl.addSignal2('Type',dOutType,'Name',['twdlXdin_',int2str(inIndex+1),'_re']);%#ok<*AGROW>
                        twdlXdin_re(inIndex+1).SimulinkRate=dataRate;
                        twdlXdin_im(inIndex+1)=FFTImpl.addSignal2('Type',dOutType,'Name',['twdlXdin_',int2str(inIndex+1),'_im']);%#ok<*AGROW>
                        twdlXdin_im(inIndex+1).SimulinkRate=dataRate;
                        twdlXdin_vld(inIndex)=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['twdlXdin_',int2str(inIndex),'_vld']);%#ok<*AGROW>
                        twdlXdin_vld(inIndex).SimulinkRate=dataRate;

                        TWDLMULT=this.elabTWDLMULT_SDNF1(FFTImpl,blockInfo,R2Stage,dataRate,needMultiplier,BITREVERSEDINPUT,multByOne1,multByOne2,...
                        DATA_WORDLENGTH,DATA_FRACTIONLENGTH,TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH,...
                        din_re(inIndex),din_im(inIndex),din_re(inIndex+1),din_im(inIndex+1),din_vld,...
                        twdl_re(inIndex),twdl_im(inIndex),twdl_re(inIndex+1),twdl_im(inIndex+1),twdl_vld(inIndex+1),softReset,...
                        twdlXdin_re(inIndex),twdlXdin_im(inIndex),twdlXdin_re(inIndex+1),twdlXdin_im(inIndex+1),twdlXdin_vld(inIndex));
                        pirelab.instantiateNetwork(FFTImpl,TWDLMULT,[din_re(inIndex),din_im(inIndex),din_re(inIndex+1),din_im(inIndex+1),din_vld,...
                        twdl_re(inIndex),twdl_im(inIndex),twdl_re(inIndex+1),twdl_im(inIndex+1),twdl_vld(inIndex+1),softReset],...
                        [twdlXdin_re(inIndex),twdlXdin_im(inIndex),twdlXdin_re(inIndex+1),twdlXdin_im(inIndex+1),twdlXdin_vld(inIndex)],...
                        ['TWDLMULT_SDNF1','_',int2str(R2Stage),'_',int2str(inIndex)]);
                    end
                end


                if R2Stage~=1
                    twdlXdin_re=reroute(twdlXdin_re,iter);
                    twdlXdin_im=reroute(twdlXdin_im,iter);
                end

                for inIndex=1:2:(DATA_VECSIZE)

                    dout_re(inIndex)=FFTImpl.addSignal2('Type',dOutType,'Name',['dout_',int2str(inIndex),'_re']);%#ok<*AGROW>
                    dout_re(inIndex).SimulinkRate=dataRate;
                    dout_im(inIndex)=FFTImpl.addSignal2('Type',dOutType,'Name',['dout_',int2str(inIndex),'_im']);%#ok<*AGROW>
                    dout_im(inIndex).SimulinkRate=dataRate;
                    dout_re(inIndex+1)=FFTImpl.addSignal2('Type',dOutType,'Name',['dout_',int2str(inIndex+1),'_re']);%#ok<*AGROW>
                    dout_re(inIndex+1).SimulinkRate=dataRate;
                    dout_im(inIndex+1)=FFTImpl.addSignal2('Type',dOutType,'Name',['dout_',int2str(inIndex+1),'_im']);%#ok<*AGROW>
                    dout_im(inIndex+1).SimulinkRate=dataRate;
                    dout_vld(inIndex)=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['dout_',int2str(inIndex),'_vld']);%#ok<*AGROW>
                    dout_vld(inIndex).SimulinkRate=dataRate;

                    SDNF1=this.elabRADIX22FFT_SDNF1(FFTImpl,blockInfo,R2Stage,dataRate,...
                    DATA_WORDLENGTH,DATA_FRACTIONLENGTH,~BITGROWTH,...
                    twdlXdin_re(inIndex),twdlXdin_im(inIndex),twdlXdin_re(inIndex+1),twdlXdin_im(inIndex+1),twdlXdin_vld(1),softReset,...
                    dout_re(inIndex),dout_im(inIndex),dout_re(inIndex+1),dout_im(inIndex+1),dout_vld(inIndex));
                    pirelab.instantiateNetwork(FFTImpl,SDNF1,...
                    [twdlXdin_re(inIndex),twdlXdin_im(inIndex),twdlXdin_re(inIndex+1),twdlXdin_im(inIndex+1),twdlXdin_vld(1),softReset],...
                    [dout_re(inIndex),dout_im(inIndex),dout_re(inIndex+1),dout_im(inIndex+1),dout_vld(inIndex)],...
                    ['SDNF1','_',int2str(R2Stage),'_',int2str(inIndex)]);

                end

                if R2Stage~=1
                    for loop=1:log2(length(dout_re))-iter
                        dout_re=reroute(dout_re,iter);
                        dout_im=reroute(dout_im,iter);
                    end
                end
                iter=iter-1;
                MEMSIZE=MEMSIZE+1;
            end


            din_vld=dout_vld(1);
            for inIndex=1:DATA_VECSIZE
                din_re(inIndex)=dout_re(inIndex);
                din_im(inIndex)=dout_im(inIndex);
            end



            R2Stage=R22Stage+1;
            BITGROWTH=(~blockInfo.Normalize)*blockInfo.BitGrowthVector(R2Stage);
            DATA_WORDLENGTH=DATA_WORDLENGTH+BITGROWTH;
            dOutType=pir_sfixpt_t(dOutType.WordLength+(~blockInfo.Normalize)*blockInfo.BitGrowthVector(R2Stage),DATA_FRACTIONLENGTH);


            if MEMSIZE>0

                rdEnb=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['rd_',int2str(R2Stage),'_Enb']);%#ok<*AGROW>
                rdEnb.SimulinkRate=dataRate;
                if MEMSIZE>1
                    rdAddr=FFTImpl.addSignal2('Type',pir_fixpt_t(0,log2(MEMSIZE),0),'Name',['rd_',int2str(R2Stage),'_Addr']);%#ok<*AGROW>
                    rdAddr.SimulinkRate=dataRate;
                elseif MEMSIZE==1
                    rdAddr=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['rd_',int2str(R2Stage),'_Addr']);%#ok<*AGROW>
                    rdAddr.SimulinkRate=dataRate;
                end
                procEnb=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['proc_',int2str(R2Stage),'_enb']);%#ok<*AGROW>
                procEnb.SimulinkRate=dataRate;
                dinXTwdl_vld=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['dinXTwdl_',int2str(R2Stage),'_vld']);%#ok<*AGROW>
                dinXTwdl_vld.SimulinkRate=dataRate;

                multiply_J=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['multiply_',int2str(R2Stage),'_J']);%#ok<*AGROW>
                multiply_J.SimulinkRate=dataRate;
                ROTATION=true;

                if DATA_VECSIZE>1
                    JMULTIPLICATION=[false(1,DATA_VECSIZE/2),true(1,DATA_VECSIZE/2)];
                else
                    JMULTIPLICATION=false;
                end

                for inIndex=1:DATA_VECSIZE
                    dout_re(inIndex)=FFTImpl.addSignal2('Type',dOutType,'Name',['dout_',int2str(R2Stage),'_',int2str(inIndex),'_re']);%#ok<*AGROW>
                    dout_re(inIndex).SimulinkRate=dataRate;
                    dout_im(inIndex)=FFTImpl.addSignal2('Type',dOutType,'Name',['dout_',int2str(R2Stage),'_',int2str(inIndex),'_im']);%#ok<*AGROW>
                    dout_im(inIndex).SimulinkRate=dataRate;
                    dout_vld(inIndex)=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['dout_',int2str(R2Stage),'_',int2str(inIndex),'_vld']);%#ok<*AGROW>
                    dout_vld(inIndex).SimulinkRate=dataRate;
                    dinXTwdl_vld(inIndex)=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['dinXTwdl_',int2str(R2Stage),'_',int2str(inIndex),'_vld']);%#ok<*AGROW>
                    dinXTwdl_vld(inIndex).SimulinkRate=dataRate;

                    if MEMSIZE==1&&DATA_VECSIZE>1
                        multiply_JC(inIndex)=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['multiply_',int2str(R2Stage),'_',int2str(inIndex),'_JC']);%#ok<*AGROW>
                        multiply_JC(inIndex).SimulinkRate=dataRate;
                        pirelab.getConstComp(FFTImpl,multiply_JC(inIndex),JMULTIPLICATION(inIndex));
                        RX2=this.elabRADIX22FFT_SDF2(FFTImpl,blockInfo,R2Stage,MEMSIZE,dataRate,...
                        DATA_WORDLENGTH,DATA_FRACTIONLENGTH,~BITGROWTH,ROTATION,...
                        din_re(inIndex),din_im(inIndex),din_vld,rdAddr,rdEnb,...
                        procEnb,multiply_JC(inIndex),softReset,...
                        dout_re(inIndex),dout_im(inIndex),dout_vld(inIndex),dinXTwdl_vld(inIndex));
                        pirelab.instantiateNetwork(FFTImpl,RX2,[din_re(inIndex),din_im(inIndex),din_vld,rdAddr,rdEnb,...
                        procEnb,multiply_JC(inIndex),softReset],...
                        [dout_re(inIndex),dout_im(inIndex),dout_vld(inIndex),dinXTwdl_vld(inIndex)],...
                        ['SDF2','_',int2str(R2Stage),'_',int2str(inIndex)]);
                    else
                        RX2=this.elabRADIX22FFT_SDF2(FFTImpl,blockInfo,R2Stage,MEMSIZE,dataRate,...
                        DATA_WORDLENGTH,DATA_FRACTIONLENGTH,~BITGROWTH,ROTATION,...
                        din_re(inIndex),din_im(inIndex),din_vld,rdAddr,rdEnb,...
                        procEnb,multiply_J,softReset,...
                        dout_re(inIndex),dout_im(inIndex),dout_vld(inIndex),dinXTwdl_vld(inIndex));
                        pirelab.instantiateNetwork(FFTImpl,RX2,[din_re(inIndex),din_im(inIndex),din_vld,rdAddr,rdEnb,...
                        procEnb,multiply_J,softReset],...
                        [dout_re(inIndex),dout_im(inIndex),dout_vld(inIndex),dinXTwdl_vld(inIndex)],...
                        ['SDF2','_',int2str(R2Stage),'_',int2str(inIndex)]);

                    end
                end


                CTRLRX2=this.elabRADIX22FFT_CTRL(FFTImpl,dataRate,R2Stage,blockInfo,MEMSIZE,BITREVERSEDINPUT,...
                din_vld,dinXTwdl_vld(1),softReset,...
                rdAddr,rdEnb,procEnb,multiply_J);
                pirelab.instantiateNetwork(FFTImpl,CTRLRX2,[din_vld,dinXTwdl_vld(1),softReset],...
                [rdAddr,rdEnb,procEnb,multiply_J],...
                ['CTRL2','_',int2str(R2Stage),'_',int2str(inIndex)]);
                MEMSIZE=MEMSIZE*2;
            else

                din_re=reroute(din_re,iter);
                din_im=reroute(din_im,iter);
                if needCtrl(DATA_VECSIZE,FFTLENGTH,R2Stage,MEMSIZE,BITREVERSEDINPUT)

                    rotate(1)=FFTImpl.addSignal2('Type',pir_ufixpt_t(1,0),'Name',['rotate_',int2str(inIndex)]);%#ok<*AGROW>
                    rotate(1).SimulinkRate=dataRate;
                    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
                    '+dsphdlsupport','+internal','@AbstractFFT','cgireml','CTRL_SDNF2.m'),'r');
                    fcnBody=fread(fid,Inf,'char=>char')';
                    fclose(fid);

                    desc='CTRL_SDNF2';

                    CTRL_SDNF2=FFTImpl.addComponent2(...
                    'kind','cgireml',...
                    'Name','CTRL_SDNF2',...
                    'InputSignals',din_vld,...
                    'OutputSignals',rotate(1),...
                    'ExternalSynchronousResetSignal',softReset,...
                    'EMLFileName','CTRL_SDNF2',...
                    'EMLFileBody',fcnBody,...
                    'EMLParams',{},...
                    'EMLFlag_TreatInputIntsAsFixpt',true,...
                    'EMLFlag_SaturateOnIntOverflow',false,...
                    'EMLFlag_TreatInputBoolsAsUfix1',false,...
                    'BlockComment',desc);
                    CTRL_SDNF2.runConcurrencyMaximizer(0);

                    for inIndex=1:2:(DATA_VECSIZE)

                        dout_re(inIndex)=FFTImpl.addSignal2('Type',dOutType,'Name',['dout_',int2str(inIndex),'_re']);%#ok<*AGROW>
                        dout_re(inIndex).SimulinkRate=dataRate;
                        dout_im(inIndex)=FFTImpl.addSignal2('Type',dOutType,'Name',['dout_',int2str(inIndex),'_im']);%#ok<*AGROW>
                        dout_im(inIndex).SimulinkRate=dataRate;
                        dout_re(inIndex+1)=FFTImpl.addSignal2('Type',dOutType,'Name',['dout_',int2str(inIndex+1),'_re']);%#ok<*AGROW>
                        dout_re(inIndex+1).SimulinkRate=dataRate;
                        dout_im(inIndex+1)=FFTImpl.addSignal2('Type',dOutType,'Name',['dout_',int2str(inIndex+1),'_im']);%#ok<*AGROW>
                        dout_im(inIndex+1).SimulinkRate=dataRate;
                        dout_vld(inIndex)=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['dout_',int2str(R2Stage),'_vld']);%#ok<*AGROW>
                        dout_vld(inIndex).SimulinkRate=dataRate;

                        SDNF2=this.elabRADIX22FFT_SDNF2(FFTImpl,blockInfo,R2Stage,dataRate,...
                        DATA_WORDLENGTH,DATA_FRACTIONLENGTH,~BITGROWTH,...
                        rotate(1),din_re(inIndex),din_im(inIndex),din_re(inIndex+1),din_im(inIndex+1),din_vld,softReset,...
                        dout_re(inIndex),dout_im(inIndex),dout_re(inIndex+1),dout_im(inIndex+1),dout_vld(inIndex));

                        pirelab.instantiateNetwork(FFTImpl,SDNF2,[rotate(1),din_re(inIndex),din_im(inIndex),din_re(inIndex+1),din_im(inIndex+1),din_vld,softReset],...
                        [dout_re(inIndex),dout_im(inIndex),dout_re(inIndex+1),dout_im(inIndex+1),dout_vld(inIndex)],...
                        ['SDNF2','_',int2str(R2Stage),'_',int2str(inIndex)]);
                    end
                else

                    ROTATE_VALUE=JMultiplication(FFTLENGTH,BITREVERSEDINPUT,R2Stage,DATA_VECSIZE);
                    for inIndex=1:2:(DATA_VECSIZE)
                        rotate(inIndex)=FFTImpl.addSignal2('Type',pir_ufixpt_t(1,0),'Name',['rotate_',int2str(inIndex)]);%#ok<*AGROW>
                        rotate(inIndex).SimulinkRate=dataRate;
                        pirelab.getConstComp(FFTImpl,rotate(inIndex),ROTATE_VALUE(inIndex));

                        dout_re(inIndex)=FFTImpl.addSignal2('Type',dOutType,'Name',['dout_',int2str(inIndex),'_re']);%#ok<*AGROW>
                        dout_re(inIndex).SimulinkRate=dataRate;
                        dout_im(inIndex)=FFTImpl.addSignal2('Type',dOutType,'Name',['dout_',int2str(inIndex),'_im']);%#ok<*AGROW>
                        dout_im(inIndex).SimulinkRate=dataRate;
                        dout_re(inIndex+1)=FFTImpl.addSignal2('Type',dOutType,'Name',['dout_',int2str(inIndex+1),'_re']);%#ok<*AGROW>
                        dout_re(inIndex+1).SimulinkRate=dataRate;
                        dout_im(inIndex+1)=FFTImpl.addSignal2('Type',dOutType,'Name',['dout_',int2str(inIndex+1),'_im']);%#ok<*AGROW>
                        dout_im(inIndex+1).SimulinkRate=dataRate;
                        dout_vld(inIndex)=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['dout_',int2str(R2Stage),'_vld']);%#ok<*AGROW>
                        dout_vld(inIndex).SimulinkRate=dataRate;

                        SDNF2=this.elabRADIX22FFT_SDNF2(FFTImpl,blockInfo,R2Stage,dataRate,...
                        DATA_WORDLENGTH,DATA_FRACTIONLENGTH,~BITGROWTH,...
                        rotate(inIndex),din_re(inIndex),din_im(inIndex),din_re(inIndex+1),din_im(inIndex+1),din_vld,softReset,...
                        dout_re(inIndex),dout_im(inIndex),dout_re(inIndex+1),dout_im(inIndex+1),dout_vld(inIndex));

                        pirelab.instantiateNetwork(FFTImpl,SDNF2,[rotate(inIndex),din_re(inIndex),din_im(inIndex),din_re(inIndex+1),din_im(inIndex+1),din_vld,softReset],...
                        [dout_re(inIndex),dout_im(inIndex),dout_re(inIndex+1),dout_im(inIndex+1),dout_vld(inIndex)],...
                        ['SDNF2','_',int2str(R2Stage),'_',int2str(inIndex)]);
                    end
                end
                for loop=1:log2(length(dout_re))-iter
                    dout_re=reroute(dout_re,iter);
                    dout_im=reroute(dout_im,iter);
                end
                iter=iter-1;
                MEMSIZE=MEMSIZE+1;
            end

            din_vld=dout_vld(1);
            for inIndex=1:DATA_VECSIZE
                din_re(inIndex)=dout_re(inIndex);
                din_im(inIndex)=dout_im(inIndex);
            end

            dOutType=pir_sfixpt_t(dOutType.WordLength+(~blockInfo.Normalize)*blockInfo.BitGrowthVector(R2Stage),DATA_FRACTIONLENGTH);

        end
    end
    if notPowerOf4

        R2Stage=2*TOTALSTAGES+1;
        BITGROWTH=(~blockInfo.Normalize)*blockInfo.BitGrowthVector(R2Stage);
        DATA_WORDLENGTH=DATA_WORDLENGTH+BITGROWTH;
        dout_vld=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['dout_',int2str(R2Stage),'_vld']);%#ok<*AGROW>
        dout_vld.SimulinkRate=dataRate;

        if MEMSIZE>0

            din_dly_type=pir_sfixpt_t(din_re(1).Type.WordLength,din_re(1).Type.FractionLength);
            rdEnb=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['rd_',int2str(R2Stage),'_Enb']);%#ok<*AGROW>
            rdEnb.SimulinkRate=dataRate;
            rdEnb_dly=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['rd_',int2str(R2Stage),'_Enb_dly']);%#ok<*AGROW>
            rdEnb_dly.SimulinkRate=dataRate;
            procEnb=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['proc_',int2str(R2Stage),'_enb']);%#ok<*AGROW>
            procEnb.SimulinkRate=dataRate;
            din_vld_dly=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['din_',int2str(R2Stage),'_vld_dly']);%#ok<*AGROW>
            din_vld_dly.SimulinkRate=dataRate;
            multiply_J=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['multiply_',int2str(R2Stage),'_J']);%#ok<*AGROW>
            multiply_J.SimulinkRate=dataRate;
            pirelab.getIntDelayEnabledResettableComp(FFTImpl,din_vld,din_vld_dly,'',softReset,3);
            pirelab.getIntDelayEnabledResettableComp(FFTImpl,rdEnb,rdEnb_dly,'',softReset,1);

            if MEMSIZE==1
                rdAddr=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['rd_',int2str(R2Stage),'_Addr']);%#ok<*AGROW>
            else
                rdAddrType=pir_fixpt_t(0,log2(MEMSIZE),0);
                rdAddr=FFTImpl.addSignal2('Type',rdAddrType,'Name',['rd_',int2str(R2Stage),'_Addr']);%#ok<*AGROW>
            end
            rdAddr.SimulinkRate=dataRate;
            for index=1:DATA_VECSIZE
                dout_re(index)=FFTImpl.addSignal2('Type',dOutType,'Name',['dout_',int2str(R2Stage),'_re']);%#ok<*AGROW>
                dout_re(index).SimulinkRate=dataRate;
                dout_im(index)=FFTImpl.addSignal2('Type',dOutType,'Name',['dout_',int2str(R2Stage),'_im']);%#ok<*AGROW>
                dout_im(index).SimulinkRate=dataRate;
                dout_vld(index)=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['dout_',int2str(R2Stage),'_vld']);%#ok<*AGROW>
                dout_vld(index).SimulinkRate=dataRate;
                dinXTwdl_vld(index)=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['dinXTwdl_',int2str(R2Stage),'_vld']);%#ok<*AGROW>
                dinXTwdl_vld(index).SimulinkRate=dataRate;


                din_re_dly(index)=FFTImpl.addSignal2('Type',din_dly_type,'Name',['din_',int2str(R2Stage),'_re_dly']);%#ok<*AGROW>
                din_re_dly(index).SimulinkRate=dataRate;
                din_im_dly(index)=FFTImpl.addSignal2('Type',din_dly_type,'Name',['din_',int2str(R2Stage),'_im_dly']);%#ok<*AGROW>
                din_im_dly(index).SimulinkRate=dataRate;

                pirelab.getIntDelayEnabledResettableComp(FFTImpl,din_re(index),din_re_dly(index),'',softReset,3);
                pirelab.getIntDelayEnabledResettableComp(FFTImpl,din_im(index),din_im_dly(index),'',softReset,3);





                twdl_rd(index)=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['twdl_',int2str(R2Stage),'_rd']);%#ok<*AGROW>
                twdl_rd(index).SimulinkRate=dataRate;
                twdl_vld(index)=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['twdl_',int2str(R2Stage),'_vld']);%#ok<*AGROW>
                twdl_vld(index).SimulinkRate=dataRate;
                twdl_re(index)=FFTImpl.addSignal2('Type',pir_sfixpt_t(TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH),'Name',['twdl_',int2str(R2Stage),'_re']);%#ok<*AGROW>
                twdl_re(index).SimulinkRate=dataRate;
                twdl_im(index)=FFTImpl.addSignal2('Type',pir_sfixpt_t(TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH),'Name',['twdl_',int2str(R2Stage),'_im']);%#ok<*AGROW>
                twdl_im(index).SimulinkRate=dataRate;

                twdlROM=this.elabRADIX22FFT_TWDL(FFTImpl,blockInfo,dataRate,R2Stage,index,DATA_VECSIZE,BITREVERSEDINPUT,0,...
                din_vld,softReset,...
                twdl_re(index),twdl_im(index),twdl_vld(index));
                pirelab.instantiateNetwork(FFTImpl,twdlROM,[din_vld,softReset],...
                [twdl_re(index),twdl_im(index),twdl_vld(index)],...
                ['twdlROM','_',int2str(R2Stage)]);

                RX2=this.elabRADIX22FFT_SDF1(FFTImpl,blockInfo,R2Stage,MEMSIZE,dataRate,BITREVERSEDINPUT,...
                DATA_WORDLENGTH,DATA_FRACTIONLENGTH,TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH,~BITGROWTH,...
                din_re_dly(index),din_im_dly(index),din_vld_dly,rdAddr,rdEnb_dly,...
                twdl_re(index),twdl_im(index),twdl_vld(index),...
                procEnb,softReset,...
                dout_re(index),dout_im(index),dout_vld(index),dinXTwdl_vld(index));
                pirelab.instantiateNetwork(FFTImpl,RX2,[din_re_dly(index),din_im_dly(index),din_vld_dly,rdAddr,rdEnb_dly,...
                twdl_re(index),twdl_im(index),twdl_vld(index),...
                procEnb,softReset],...
                [dout_re(index),dout_im(index),dout_vld(index),dinXTwdl_vld(index)],...
                'RADIX2');

            end
            CTRLRX2=this.elabRADIX22FFT_CTRL(FFTImpl,dataRate,inIndex,blockInfo,MEMSIZE,BITREVERSEDINPUT,...
            dinXTwdl_vld(1),dinXTwdl_vld(1),softReset,...
            rdAddr,rdEnb,procEnb,multiply_J);
            pirelab.instantiateNetwork(FFTImpl,CTRLRX2,[dinXTwdl_vld(1),dinXTwdl_vld(1),softReset],...
            [rdAddr,rdEnb,procEnb,multiply_J],...
            'CTRLRX2');
        else

            din_re=reroute(din_re,iter);
            din_im=reroute(din_im,iter);

            multByOneV=multByOneVector(R2Stage);
            for inIndex=1:DATA_VECSIZE
                twdl_re(inIndex)=FFTImpl.addSignal2('Type',pir_sfixpt_t(TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH),'Name',['twdl_',int2str(R2Stage),'_',int2str(inIndex),'_re']);%#ok<*AGROW>
                twdl_re(inIndex).SimulinkRate=dataRate;
                twdl_im(inIndex)=FFTImpl.addSignal2('Type',pir_sfixpt_t(TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH),'Name',['twdl_',int2str(R2Stage),'_',int2str(inIndex),'_im']);%#ok<*AGROW>
                twdl_im(inIndex).SimulinkRate=dataRate;
                twdl_vld(inIndex)=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['twdl_',int2str(R2Stage),'_vld']);%#ok<*AGROW>
                twdl_vld(inIndex).SimulinkRate=dataRate;

                if BITREVERSEDINPUT
                    if multByOneV(inIndex)

                        pirelab.getConstComp(FFTImpl,twdl_re(inIndex),1);
                        pirelab.getConstComp(FFTImpl,twdl_im(inIndex),0);
                        pirelab.getConstComp(FFTImpl,twdl_vld(inIndex),true);
                        multByOne1X(inIndex)=1;

                    else
                        twdlROM=this.elabRADIX22FFT_TWDL(FFTImpl,blockInfo,dataRate,R2Stage,inIndex,DATA_VECSIZE,BITREVERSEDINPUT,1,...
                        din_vld,softReset,...
                        twdl_re(inIndex),twdl_im(inIndex),twdl_vld(inIndex));
                        pirelab.instantiateNetwork(FFTImpl,twdlROM,[din_vld,softReset],...
                        [twdl_re(inIndex),twdl_im(inIndex),twdl_vld(inIndex)],...
                        ['twdlROM','_',int2str(R2Stage),'_',int2str(inIndex)]);
                        multByOne1X(inIndex)=0;
                    end

                else
                    if mod(inIndex,2)

                        pirelab.getConstComp(FFTImpl,twdl_re(inIndex),1);
                        pirelab.getConstComp(FFTImpl,twdl_im(inIndex),0);
                        pirelab.getConstComp(FFTImpl,twdl_vld(inIndex),true);
                        multByOne1X(inIndex)=1;

                    else
                        twdlROM=this.elabRADIX22FFT_TWDL(FFTImpl,blockInfo,dataRate,R2Stage,inIndex,DATA_VECSIZE,BITREVERSEDINPUT,1,...
                        din_vld,softReset,...
                        twdl_re(inIndex),twdl_im(inIndex),twdl_vld(inIndex));
                        pirelab.instantiateNetwork(FFTImpl,twdlROM,[din_vld,softReset],...
                        [twdl_re(inIndex),twdl_im(inIndex),twdl_vld(inIndex)],...
                        ['twdlROM','_',int2str(R2Stage),'_',int2str(inIndex)]);
                        multByOne1X(inIndex)=0;
                    end
                end
            end
            for inIndex=1:2:(DATA_VECSIZE)

                dout_re(inIndex)=FFTImpl.addSignal2('Type',dOutType,'Name',['dout_',int2str(inIndex),'_re']);%#ok<*AGROW>
                dout_re(inIndex).SimulinkRate=dataRate;
                dout_im(inIndex)=FFTImpl.addSignal2('Type',dOutType,'Name',['dout_',int2str(inIndex),'_im']);%#ok<*AGROW>
                dout_im(inIndex).SimulinkRate=dataRate;
                dout_re(inIndex+1)=FFTImpl.addSignal2('Type',dOutType,'Name',['dout_',int2str(inIndex+1),'_re']);%#ok<*AGROW>
                dout_re(inIndex+1).SimulinkRate=dataRate;
                dout_im(inIndex+1)=FFTImpl.addSignal2('Type',dOutType,'Name',['dout_',int2str(inIndex+1),'_im']);%#ok<*AGROW>
                dout_im(inIndex+1).SimulinkRate=dataRate;
                dout_vld(inIndex)=FFTImpl.addSignal2('Type',pir_boolean_t,'Name',['dout_',int2str(inIndex+1),'_vld']);%#ok<*AGROW>
                dout_vld(inIndex).SimulinkRate=dataRate;
                SDNF1=this.elabRADIX22FFT_SDNF1X(FFTImpl,blockInfo,R2Stage,dataRate,BITREVERSEDINPUT,multByOne1X(inIndex),multByOne1X(inIndex+1),...
                DATA_WORDLENGTH,DATA_FRACTIONLENGTH,TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH,~BITGROWTH,...
                din_re(inIndex),din_im(inIndex),din_re(inIndex+1),din_im(inIndex+1),din_vld,...
                twdl_re(inIndex),twdl_im(inIndex),twdl_re(inIndex+1),twdl_im(inIndex+1),twdl_vld(2),softReset,...
                dout_re(inIndex),dout_im(inIndex),dout_re(inIndex+1),dout_im(inIndex+1),dout_vld(inIndex));
                pirelab.instantiateNetwork(FFTImpl,SDNF1,[din_re(inIndex),din_im(inIndex),din_re(inIndex+1),din_im(inIndex+1),din_vld,...
                twdl_re(inIndex),twdl_im(inIndex),twdl_re(inIndex+1),twdl_im(inIndex+1),twdl_vld(2),softReset],...
                [dout_re(inIndex),dout_im(inIndex),dout_re(inIndex+1),dout_im(inIndex+1),dout_vld(inIndex)],...
                ['SDNF1','_',int2str(R2Stage),'_',int2str(inIndex)]);

            end
            for loop=1:log2(length(dout_re))-iter
                dout_re=reroute(dout_re,iter);
                dout_im=reroute(dout_im,iter);
            end
        end
    end




    if~xor(blockInfo.BitReversedOutput,blockInfo.BitReversedInput)

        if DATA_VECSIZE==1
            inIndex=1;
            din_re=dout_re(inIndex);
            din_im=dout_im(inIndex);
            din_vld=dout_vld(1);
            dout_re(inIndex)=FFTImpl.addSignal2('Type',din_re.Type,'Name',['dout_re',int2str(inIndex)]);
            dout_re(inIndex).SimulinkRate=dataRate;
            dout_im(inIndex)=FFTImpl.addSignal2('Type',din_re.Type,'Name',['dout_im',int2str(inIndex)]);
            dout_im(inIndex).SimulinkRate=dataRate;
            dout_vld=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name',['dout_vld',int2str(inIndex)]);
            dout_vld.SimulinkRate=dataRate;
            if blockInfo.outMode(1)&&blockInfo.outMode(2)
                startOutS=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name','startOutS');
                startOutS.SimulinkRate=dataRate;
                endOutS=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name','endOutS');
                endOutS.SimulinkRate=dataRate;
                FFT_bitNatural=this.elabRADIX2FFT_bitNatural(FFTImpl,blockInfo,dataRate,din_re,din_im,din_vld,softReset,...
                dout_re(inIndex),dout_im(inIndex),dout_vld,startOutS,endOutS);
                pirelab.instantiateNetwork(FFTImpl,FFT_bitNatural,[din_re,din_im,din_vld,softReset],...
                [dout_re(inIndex),dout_im(inIndex),dout_vld,startOutS,endOutS],'NaturalOrder_Stage');
            elseif blockInfo.outMode(1)
                startOutS=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name','startOutS');
                startOutS.SimulinkRate=dataRate;

                FFT_bitNatural=this.elabRADIX2FFT_bitNatural(FFTImpl,blockInfo,dataRate,din_re,din_im,din_vld,softReset,...
                dout_re(inIndex),dout_im(inIndex),dout_vld,startOutS,[]);
                pirelab.instantiateNetwork(FFTImpl,FFT_bitNatural,[din_re,din_im,din_vld,softReset],...
                [dout_re(inIndex),dout_im(inIndex),dout_vld,startOutS,[]],'NaturalOrder_Stage');
            elseif blockInfo.outMode(2)
                endOutS=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name','endOutS');
                endOutS.SimulinkRate=dataRate;
                FFT_bitNatural=this.elabRADIX2FFT_bitNatural(FFTImpl,blockInfo,dataRate,din_re,din_im,din_vld,softReset,...
                dout_re(inIndex),dout_im(inIndex),dout_vld,[],endOutS);
                pirelab.instantiateNetwork(FFTImpl,FFT_bitNatural,[din_re,din_im,din_vld,softReset],...
                [dout_re(inIndex),dout_im(inIndex),dout_vld,[],endOutS],'NaturalOrder_Stage');
            else
                FFT_bitNatural=this.elabRADIX2FFT_bitNatural(FFTImpl,blockInfo,dataRate,din_re,din_im,din_vld,softReset,...
                dout_re(inIndex),dout_im(inIndex),dout_vld,[],[]);
                pirelab.instantiateNetwork(FFTImpl,FFT_bitNatural,[din_re,din_im,din_vld,softReset],...
                [dout_re(inIndex),dout_im(inIndex),dout_vld,[],[]],'NaturalOrder_Stage');
            end
        elseif DATA_VECSIZE==FFTLENGTH
            din_re=dout_re(bitrevorder(1:1:FFTLENGTH));
            din_im=dout_im(bitrevorder(1:1:FFTLENGTH));
            din_vld=dout_vld(1);
            for inIndex=1:DATA_VECSIZE
                dout_re(inIndex)=FFTImpl.addSignal2('Type',din_re(inIndex).Type,'Name',['dout_re',int2str(inIndex)]);
                dout_re(inIndex).SimulinkRate=dataRate;
                dout_im(inIndex)=FFTImpl.addSignal2('Type',din_im(inIndex).Type,'Name',['dout_im',int2str(inIndex)]);
                dout_im(inIndex).SimulinkRate=dataRate;
                pirelab.getWireComp(FFTImpl,din_re(inIndex),dout_re(inIndex));
                pirelab.getWireComp(FFTImpl,din_im(inIndex),dout_im(inIndex));
            end
            dout_vld=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name','dout_vld');
            dout_vld.SimulinkRate=dataRate;
            pirelab.getWireComp(FFTImpl,din_vld,dout_vld);
        else
            hAF=hdlcoder.tpc_arr_factory;
            hAF.addDimension(DATA_VECSIZE);
            hAF.addBaseType(dout_re(1).Type);
            hAF.VectorOrientation='column';
            dType_array=hdlcoder.tp_array(hAF);
            dout_re_v=FFTImpl.addSignal2('Type',dType_array,'Name','dout_re_v');
            dout_re_v.SimulinkRate=dataRate;
            dout_im_v=FFTImpl.addSignal2('Type',dType_array,'Name','dout_im_v');
            dout_im_v.SimulinkRate=dataRate;
            pirelab.getMuxComp(FFTImpl,dout_re,dout_re_v);
            pirelab.getMuxComp(FFTImpl,dout_im,dout_im_v);
            for inIndex=1:DATA_VECSIZE
                din_re=dout_re_v;
                din_im=dout_im_v;
                din_vld=dout_vld(1);
                dMem_re(inIndex)=FFTImpl.addSignal2('Type',dout_re(1).Type,'Name',['dMem_re',int2str(inIndex)]);
                dMem_re(inIndex).SimulinkRate=dataRate;
                dMem_im(inIndex)=FFTImpl.addSignal2('Type',dout_re(1).Type,'Name',['dMem_im',int2str(inIndex)]);
                dMem_im(inIndex).SimulinkRate=dataRate;
                dMem_vld(inIndex)=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name',['dMem_vld',int2str(inIndex)]);
                dMem_vld(inIndex).SimulinkRate=dataRate;
                if blockInfo.outMode(1)&&blockInfo.outMode(2)
                    startOutO=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name','startOutO');
                    startOutO.SimulinkRate=dataRate;
                    endOutO=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name','endOutO');
                    endOutO.SimulinkRate=dataRate;
                    FFT_bitNatural=this.elabRADIX22FFT_bitNatural(FFTImpl,blockInfo,dataRate,DATA_VECSIZE,inIndex,din_re,din_im,din_vld,softReset,...
                    dMem_re(inIndex),dMem_im(inIndex),dMem_vld(inIndex),startOutO,endOutO);
                    pirelab.instantiateNetwork(FFTImpl,FFT_bitNatural,[din_re,din_im,din_vld,softReset],...
                    [dMem_re(inIndex),dMem_im(inIndex),dMem_vld(inIndex),startOutO,endOutO],'NaturalOrder_Stage');
                elseif blockInfo.outMode(1)
                    startOutO=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name','startOutO');
                    startOutO.SimulinkRate=dataRate;

                    FFT_bitNatural=this.elabRADIX22FFT_bitNatural(FFTImpl,blockInfo,dataRate,DATA_VECSIZE,inIndex,din_re,din_im,din_vld,softReset,...
                    dMem_re(inIndex),dMem_im(inIndex),dMem_vld(inIndex),startOutO,[]);
                    pirelab.instantiateNetwork(FFTImpl,FFT_bitNatural,[din_re,din_im,din_vld,softReset],...
                    [dMem_re(inIndex),dMem_im(inIndex),dMem_vld(inIndex),startOutO,[]],'NaturalOrder_Stage');
                elseif blockInfo.outMode(2)
                    endOutO=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name','endOutO');
                    endOutO.SimulinkRate=dataRate;
                    FFT_bitNatural=this.elabRADIX22FFT_bitNatural(FFTImpl,blockInfo,dataRate,DATA_VECSIZE,inIndex,din_re,din_im,din_vld,softReset,...
                    dMem_re(inIndex),dMem_im(inIndex),dMem_vld(inIndex),[],endOutO);
                    pirelab.instantiateNetwork(FFTImpl,FFT_bitNatural,[din_re,din_im,din_vld,softReset],...
                    [dMem_re(inIndex),dMem_im(inIndex),dMem_vld(inIndex),[],endOutO],'NaturalOrder_Stage');
                else
                    FFT_bitNatural=this.elabRADIX22FFT_bitNatural(FFTImpl,blockInfo,dataRate,DATA_VECSIZE,inIndex,din_re,din_im,din_vld,softReset,...
                    dMem_re(inIndex),dMem_im(inIndex),dMem_vld(inIndex),[],[]);
                    pirelab.instantiateNetwork(FFTImpl,FFT_bitNatural,[din_re,din_im,din_vld,softReset],...
                    [dMem_re(inIndex),dMem_im(inIndex),dMem_vld(inIndex),[],[]],'NaturalOrder_Stage');
                end
            end
            dMem_re_v=FFTImpl.addSignal2('Type',dType_array,'Name','dMem_re_v');
            dMem_re_v.SimulinkRate=dataRate;
            dMem_im_v=FFTImpl.addSignal2('Type',dType_array,'Name','dMem_im_v');
            dMem_im_v.SimulinkRate=dataRate;
            pirelab.getMuxComp(FFTImpl,dMem_re,dMem_re_v);
            pirelab.getMuxComp(FFTImpl,dMem_im,dMem_im_v);
            for inIndex=1:DATA_VECSIZE
                dMux_re(inIndex)=FFTImpl.addSignal2('Type',dout_re(1).Type,'Name',['dMux_re',int2str(inIndex)]);
                dMux_re(inIndex).SimulinkRate=dataRate;
                dMux_im(inIndex)=FFTImpl.addSignal2('Type',dout_re(1).Type,'Name',['dMux_im',int2str(inIndex)]);
                dMux_im(inIndex).SimulinkRate=dataRate;
                dMux_vld(inIndex)=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name',['dMux_vld',int2str(inIndex)]);
                dMux_vld(inIndex).SimulinkRate=dataRate;
                if blockInfo.outMode(1)&&blockInfo.outMode(2)
                    FFT_bitNaturalMux=this.elabRADIX22FFT_bitNaturalMux(FFTImpl,blockInfo,dataRate,DATA_VECSIZE,inIndex,dMem_re_v,dMem_im_v,dMem_vld(1),softReset,...
                    dMux_re(inIndex),dMux_im(inIndex),dMux_vld(inIndex));
                    pirelab.instantiateNetwork(FFTImpl,FFT_bitNaturalMux,[dMem_re_v,dMem_im_v,dMem_vld(1),softReset],...
                    [dMux_re(inIndex),dMux_im(inIndex),dMux_vld(inIndex)],'NaturalOrder_OutMux');
                elseif blockInfo.outMode(1)
                    FFT_bitNaturalMux=this.elabRADIX22FFT_bitNaturalMux(FFTImpl,blockInfo,dataRate,DATA_VECSIZE,inIndex,dMem_re_v,dMem_im_v,dMem_vld(1),softReset,...
                    dMux_re(inIndex),dMux_im(inIndex),dMux_vld(inIndex));
                    pirelab.instantiateNetwork(FFTImpl,FFT_bitNaturalMux,[dMem_re_v,dMem_im_v,dMem_vld(1),softReset],...
                    [dMux_re(inIndex),dMux_im(inIndex),dMux_vld(inIndex)],'NaturalOrder_OutMux');
                elseif blockInfo.outMode(2)
                    FFT_bitNaturalMux=this.elabRADIX22FFT_bitNaturalMux(FFTImpl,blockInfo,dataRate,DATA_VECSIZE,inIndex,dMem_re_v,dMem_im_v,dMem_vld(1),softReset,...
                    dMux_re(inIndex),dMux_im(inIndex),dMux_vld(inIndex));
                    pirelab.instantiateNetwork(FFTImpl,FFT_bitNaturalMux,[dMem_re_v,dMem_im_v,dMem_vld(1),softReset],...
                    [dMux_re(inIndex),dMux_im(inIndex),dMux_vld(inIndex)],'NaturalOrder_OutMux');
                else
                    FFT_bitNaturalMux=this.elabRADIX22FFT_bitNaturalMux(FFTImpl,blockInfo,dataRate,DATA_VECSIZE,inIndex,dMem_re_v,dMem_im_v,dMem_vld(1),softReset,...
                    dMux_re(inIndex),dMux_im(inIndex),dMux_vld(inIndex));
                    pirelab.instantiateNetwork(FFTImpl,FFT_bitNaturalMux,[dMem_re_v,dMem_im_v,dMem_vld(1),softReset],...
                    [dMux_re(inIndex),dMux_im(inIndex),dMux_vld(inIndex)],'NaturalOrder_OutMux');
                end
            end

            dly=1+log2(double(DATA_VECSIZE));
            if blockInfo.outMode(1)&&blockInfo.outMode(2)
                startOutS=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name','startOutS');
                startOutS.SimulinkRate=dataRate;
                endOutS=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name','endOutS');
                endOutS.SimulinkRate=dataRate;
                pirelab.getIntDelayEnabledResettableComp(FFTImpl,startOutO,startOutS,'',softReset,dly);
                pirelab.getIntDelayEnabledResettableComp(FFTImpl,endOutO,endOutS,'',softReset,dly);
            elseif blockInfo.outMode(1)
                startOutS=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name','startOutS');
                startOutS.SimulinkRate=dataRate;
                pirelab.getIntDelayEnabledResettableComp(FFTImpl,startOutO,startOutS,'',softReset,dly);
            elseif blockInfo.outMode(2)
                endOutS=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name','endOutS');
                endOutS.SimulinkRate=dataRate;
                pirelab.getIntDelayEnabledResettableComp(FFTImpl,endOutO,endOutS,'',softReset,dly);
            end
            dout_re=dMux_re;
            dout_im=dMux_im;
            dout_vld(1)=dMux_vld(1);
        end
    end




    if blockInfo.inverseFFT
        dout_tmp=dout_re;
        dout_re=dout_im;
        dout_im=dout_tmp;
    end


    VLDLEN=log2(double(FFTLENGTH/DATA_VECSIZE));
    if blockInfo.outMode(1)&&xor(blockInfo.BitReversedOutput,blockInfo.BitReversedInput)||DATA_VECSIZE==FFTLENGTH

        startOutS=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name','startOutS');
        startOutS.SimulinkRate=dataRate;
        if VLDLEN==0
            pirelab.getWireComp(FFTImpl,dout_vld(1),startOutS);
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
            'ExternalSynchronousResetSignal',softReset,...
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


    if blockInfo.outMode(2)&&xor(blockInfo.BitReversedOutput,blockInfo.BitReversedInput)||DATA_VECSIZE==FFTLENGTH

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
            'ExternalSynchronousResetSignal',softReset,...
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
        pirelab.getWireComp(FFTImpl,dout_vld(1),outsignals(4));
    elseif blockInfo.outMode(1)
        pirelab.getWireComp(FFTImpl,startOutS,outsignals(2));
        pirelab.getWireComp(FFTImpl,dout_vld(1),outsignals(3));
    elseif blockInfo.outMode(2)
        pirelab.getWireComp(FFTImpl,endOutS,outsignals(2));
        pirelab.getWireComp(FFTImpl,dout_vld(1),outsignals(3));
    else
        pirelab.getWireComp(FFTImpl,dout_vld(1),outsignals(2));
    end




    function[outVect]=reroute(inVect,iter)



        Len=length(inVect);
        step=Len/(2^iter);
        outVect=inVect;
        firstIdx=1;
        lastIdx=firstIdx+Len/(2^iter)-1;
        for loop1=1:1:(2^(iter-1))
            incr=0;
            for loop2=firstIdx:1:lastIdx
                outVect(loop2+incr)=inVect(loop2);
                outVect(loop2+incr+1)=inVect(loop2+step);
                incr=incr+1;
            end
            firstIdx=lastIdx+step+1;
            lastIdx=firstIdx+Len/(2^iter)-1;
        end

        function insertCtrl=needCtrl(inVect,FFTLength,stageNumber,MEMSIZE,BITRIVERSEDINPUT)


























            if~BITRIVERSEDINPUT
                insertCtrl=false;
                requireInputs=4*(FFTLength/2^stageNumber);
                if inVect<requireInputs
                    insertCtrl=true;
                end
            else
                if MEMSIZE<=0
                    insertCtrl=false;
                else
                    insertCtrl=false;
                    requireInputs=4*(FFTLength/2^stageNumber);
                    if inVect<requireInputs
                        insertCtrl=true;
                    end

                end
            end

            function rotateVector=JMultiplication(FFTLength,BITREVERSEDINPUT,stageNumber,InVect)




                if~BITREVERSEDINPUT
                    totalNoOfBtfProc=FFTLength/2;
                    noOfBtfProcPerStage=FFTLength/2^stageNumber;



                    rotateVector=[zeros(noOfBtfProcPerStage,1);ones(noOfBtfProcPerStage,1)]';

                    rotateVector=repmat(rotateVector,1,totalNoOfBtfProc/(2*noOfBtfProcPerStage));
                else
                    rotateVector=[false(1,2^(stageNumber-1)),true(1,2^(stageNumber-1))];
                    rotateVector=repmat(rotateVector,1,InVect/2^(stageNumber));
                end



                function status=requireMultiplication(inIndex,stageNum,notPowerOf4)
                    status=true;
                    if notPowerOf4
                        exp=stageNum+2;
                    else
                        exp=stageNum+1;
                    end
                    if~rem(inIndex-1,2^exp)
                        status=false;
                    end


                    function status=multByOne(STAGENUMBER,INVECSIZE,inIndex)
                        CNT_INC=INVECSIZE/(4*2^(STAGENUMBER-3));
                        REPEAT=STAGENUMBER-3;
                        PHASE_IC=repmat([repmat(0,1,2^REPEAT),repmat(1,1,2^REPEAT),repmat(2,1,2^REPEAT),repmat(3,1,2^REPEAT)],1,CNT_INC);%#ok<REPMAT>
                        status=false;
                        if PHASE_IC(inIndex)==0
                            status=true;
                        end


                        function status=multByOneVector(STAGENUMBER)
                            REPEAT=STAGENUMBER-3;
                            CNT_IC=repmat([0,1],1,4*2^REPEAT);
                            PHASE_IC=[repmat([0,0],1,2^REPEAT),repmat([1,1],1,2^REPEAT),repmat([2,2],1,2^REPEAT),repmat([3,3],1,2^REPEAT)];
                            status=~logical(CNT_IC.*PHASE_IC);










