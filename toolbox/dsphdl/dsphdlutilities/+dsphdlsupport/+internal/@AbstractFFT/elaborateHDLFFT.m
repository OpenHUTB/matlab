function elaborateHDLFFT(this,FFTImpl,blockInfo)









    insignals=FFTImpl.PirInputSignals;
    inRate=insignals(1).SimulinkRate;

    outsignals=FFTImpl.PirOutputSignals;



    dataIn=insignals(1);
    dataRate=dataIn.simulinkRate;
    validIn=insignals(2);
    validIn.SimulinkRate=dataRate;




    if blockInfo.inMode(2)
        softReset=insignals(3);
        softReset.SimulinkRate=dataRate;
    else
        softReset=FFTImpl.addSignal2('Type',pir_boolean_t,'Name','softReset');
        softReset.SimulinkRate=dataRate;
        pirelab.getConstComp(FFTImpl,softReset,false);
        if blockInfo.inResetSS


            softReset.setSynthResetInsideResetSS;

            blockInfo.inMode(2)=true;
        else


            pirelab.getConstComp(FFTImpl,softReset,false);
        end
    end
    if~isa(dataIn.Type,'hdlcoder.tp_complex')
        DATA_SIGN=dataIn.Type.Signed;
        DATA_WORDLENGTH=dataIn.Type.WordLength;
        DATA_FRACTIONLENGTH=dataIn.Type.FractionLength;
    else
        DATA_SIGN=dataIn.Type.BaseType.Signed;
        DATA_WORDLENGTH=dataIn.Type.BaseType.WordLength;
        DATA_FRACTIONLENGTH=dataIn.Type.BaseType.FractionLength;
    end
    if DATA_SIGN
        din_type=pir_fixpt_t(1,DATA_WORDLENGTH,DATA_FRACTIONLENGTH);
    else
        din_type=pir_fixpt_t(1,DATA_WORDLENGTH+1,DATA_FRACTIONLENGTH);
        DATA_WORDLENGTH=DATA_WORDLENGTH+1;
    end

    din_re(1)=FFTImpl.addSignal2('Type',din_type,'Name','din_re');
    din_re(1).SimulinkRate=dataRate;
    din_im(1)=FFTImpl.addSignal2('Type',din_type,'Name','din_im');
    din_im(1).SimulinkRate=dataRate;




    TWDL_WORDLENGTH=DATA_WORDLENGTH;
    TWDL_FRACTIONLENGTH=DATA_WORDLENGTH-2;
    blockInfo.TWDL_WORDLENGTH=TWDL_WORDLENGTH;
    blockInfo.TWDL_FRACTIONLENGTH=TWDL_FRACTIONLENGTH;




    blockInfo.actualFFTLength=blockInfo.FFTLength;
    dataIn_cast=FFTImpl.addSignal2('Type',pir_complex_t(pir_sfixpt_t(DATA_WORDLENGTH,DATA_FRACTIONLENGTH)),'Name','dataIn_cast');
    dataIn_cast.SimulinkRate=dataRate;
    pirelab.getDTCComp(FFTImpl,dataIn,dataIn_cast);
    pirelab.getComplex2RealImag(FFTImpl,dataIn_cast,[din_re,din_im],'real and imag');
    din_vld=validIn;
    if~isa(dataIn.Type,'hdlcoder.tp_complex')
        blockInfo.InputDataIsReal=true;
    else
        blockInfo.InputDataIsReal=false;
    end


    TOTALSTAGES=log2(blockInfo.actualFFTLength);

    dataOut=outsignals(1);




    if blockInfo.inverseFFT
        din_tmp=din_re;
        din_re=din_im;
        din_im=din_tmp;
    end



    stageOutType=pir_sfixpt_t(DATA_WORDLENGTH+blockInfo.BitGrowthVector(1),DATA_FRACTIONLENGTH);
    for stageNum=1:TOTALSTAGES-1
        stageOut(stageNum)=FFTImpl.addSignal2('Type',pir_ufixpt_t(ceil(log2(TOTALSTAGES)),0),'Name',['stageOut_',num2str(stageNum)]);
        stageOut(stageNum).SimulinkRate=dataRate;

        dout_re(stageNum)=FFTImpl.addSignal2('Type',stageOutType,'Name',['dout_re',num2str(stageNum)]);
        dout_re(stageNum).SimulinkRate=dataRate;
        dout_im(stageNum)=FFTImpl.addSignal2('Type',stageOutType,'Name',['dout_im',num2str(stageNum)]);
        dout_im(stageNum).SimulinkRate=dataRate;
        dout_vld(stageNum)=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name',['dout_vld',num2str(stageNum)]);
        dout_vld(stageNum).SimulinkRate=dataRate;
        stageIn(stageNum)=FFTImpl.addSignal2('Type',pir_ufixpt_t(ceil(log2(TOTALSTAGES)),0),'Name',['stageIn_',num2str(stageNum)]);
        stageIn(stageNum).SimulinkRate=dataRate;
        if stageNum<=3



            if stageNum==1
                stageName='First_Stage';
            elseif stageNum==2
                stageName='Second_Stage';
            else
                stageName='Third_Stage';
            end
            if stageNum==3
                PROCESS_DELAY=6;
            else
                PROCESS_DELAY=3;
            end
            FFT_stageF=this.elabRADIX2FFT_KernelF(FFTImpl,blockInfo,stageNum,PROCESS_DELAY,inRate,din_re(stageNum),din_im(stageNum),din_vld,softReset,dout_re(stageNum),dout_im(stageNum),dout_vld(stageNum));
            pirelab.instantiateNetwork(FFTImpl,FFT_stageF,[din_re(stageNum),din_im(stageNum),din_vld,softReset],...
            [dout_re(stageNum),dout_im(stageNum),dout_vld(stageNum)],stageName);

            din_re(stageNum+1)=FFTImpl.addSignal2('Type',stageOutType,'Name','din_re');
            din_re(stageNum+1).SimulinkRate=dataRate;
            din_im(stageNum+1)=FFTImpl.addSignal2('Type',stageOutType,'Name','din_im');
            din_im(stageNum+1).SimulinkRate=dataRate;
            din_re(stageNum+1)=dout_re(stageNum);
            din_im(stageNum+1)=dout_im(stageNum);
            din_vld=dout_vld(stageNum);
        else



            pirelab.getConstComp(FFTImpl,stageIn(stageNum),4);

            twiddleAddr(stageNum)=FFTImpl.addSignal2('Type',pir_ufixpt_t(stageNum-3,0),'Name',['twiddleAddr_',num2str(stageNum)]);%#ok<*AGROW>
            twiddleAddr(stageNum).SimulinkRate=dataRate;

            twiddle_re(stageNum)=FFTImpl.addSignal2('Type',pir_sfixpt_t(TWDL_WORDLENGTH,-TWDL_FRACTIONLENGTH),'Name',['twiddle_re_',num2str(stageNum)]);
            twiddle_re(stageNum).SimulinkRate=dataRate;
            twiddle_im(stageNum)=FFTImpl.addSignal2('Type',pir_sfixpt_t(TWDL_WORDLENGTH,-TWDL_FRACTIONLENGTH),'Name',['twiddle_im_',num2str(stageNum)]);
            twiddle_im(stageNum).SimulinkRate=dataRate;

            this.elabTwiddleROM(FFTImpl,blockInfo,dataRate,stageNum,twiddleAddr(stageNum),twiddle_re(stageNum),twiddle_im(stageNum));

            FFT_stageG=this.elabRADIX2FFT_KernelG(FFTImpl,blockInfo,stageNum,inRate,stageIn(stageNum),twiddle_re(stageNum),twiddle_im(stageNum),din_re(stageNum),din_im(stageNum),din_vld,softReset,...
            stageOut(stageNum),twiddleAddr(stageNum),dout_re(stageNum),dout_im(stageNum),dout_vld(stageNum));
            pirelab.instantiateNetwork(FFTImpl,FFT_stageG,[stageOut(stageNum-1),twiddle_re(stageNum),twiddle_im(stageNum),din_re(stageNum),din_im(stageNum),din_vld,softReset],...
            [stageOut(stageNum),twiddleAddr(stageNum),dout_re(stageNum),dout_im(stageNum),dout_vld(stageNum)],'Middle_Stage');
            din_re(stageNum+1)=FFTImpl.addSignal2('Type',stageOutType,'Name','din_re');
            din_re(stageNum+1).SimulinkRate=dataRate;
            din_im(stageNum+1)=FFTImpl.addSignal2('Type',stageOutType,'Name','din_im');
            din_im(stageNum+1).SimulinkRate=dataRate;
            din_re(stageNum+1)=dout_re(stageNum);
            din_im(stageNum+1)=dout_im(stageNum);
            din_vld=dout_vld(stageNum);

        end
        stageOutType=pir_sfixpt_t(stageOutType.WordLength+blockInfo.BitGrowthVector(stageNum+1),DATA_FRACTIONLENGTH);

    end




    stageNum=TOTALSTAGES;
    stageOut(stageNum)=FFTImpl.addSignal2('Type',pir_ufixpt_t(ceil(log2(TOTALSTAGES)),0),'Name',['stageOut_',num2str(stageNum)]);
    stageOut(stageNum).SimulinkRate=dataRate;
    dout_re(stageNum)=FFTImpl.addSignal2('Type',stageOutType,'Name',['dout_re',num2str(stageNum)]);
    dout_re(stageNum).SimulinkRate=dataRate;
    dout_im(stageNum)=FFTImpl.addSignal2('Type',stageOutType,'Name',['dout_im',num2str(stageNum)]);
    dout_im(stageNum).SimulinkRate=dataRate;
    dout_vld(stageNum)=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name',['dout_vld',num2str(stageNum)]);
    dout_vld(stageNum).SimulinkRate=dataRate;
    stageIn(stageNum)=FFTImpl.addSignal2('Type',pir_ufixpt_t(ceil(log2(TOTALSTAGES)),0),'Name',['stageIn_',num2str(stageNum)]);
    stageIn(stageNum).SimulinkRate=dataRate;
    if TOTALSTAGES<4
        twiddleAddr(stageNum)=FFTImpl.addSignal2('Type',pir_ufixpt_t(stageNum-2,0),'Name',['twiddleAddr_',num2str(stageNum)]);%#ok<*AGROW>
        twiddleAddr(stageNum).SimulinkRate=dataRate;
    else
        twiddleAddr(stageNum)=FFTImpl.addSignal2('Type',pir_ufixpt_t(stageNum-3,0),'Name',['twiddleAddr_',num2str(stageNum)]);%#ok<*AGROW>
        twiddleAddr(stageNum).SimulinkRate=dataRate;
    end
    twiddle_re(stageNum)=FFTImpl.addSignal2('Type',pir_sfixpt_t(TWDL_WORDLENGTH,-TWDL_FRACTIONLENGTH),'Name',['twiddle_re_',num2str(stageNum)]);
    twiddle_re(stageNum).SimulinkRate=dataRate;
    twiddle_im(stageNum)=FFTImpl.addSignal2('Type',pir_sfixpt_t(TWDL_WORDLENGTH,-TWDL_FRACTIONLENGTH),'Name',['twiddle_im_',num2str(stageNum)]);
    twiddle_im(stageNum).SimulinkRate=dataRate;

    this.elabTwiddleROM(FFTImpl,blockInfo,dataRate,stageNum,twiddleAddr(stageNum),twiddle_re(stageNum),twiddle_im(stageNum));

    if blockInfo.outMode(1)&&blockInfo.outMode(2)&&blockInfo.BitReversedOutput
        startOutS=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name','startOutS');
        startOutS.SimulinkRate=dataRate;
        endOutS=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name','endOutS');
        endOutS.SimulinkRate=dataRate;
        FFT_stageL=this.elabRADIX2FFT_KernelL(FFTImpl,blockInfo,inRate,stageIn(stageNum),twiddle_re(stageNum),twiddle_im(stageNum),din_re(stageNum),din_im(stageNum),din_vld,softReset,...
        stageOut(stageNum),twiddleAddr(stageNum),dout_re(stageNum),dout_im(stageNum),dout_vld(stageNum),startOutS,endOutS);
        pirelab.instantiateNetwork(FFTImpl,FFT_stageL,[stageOut(stageNum-1),twiddle_re(stageNum),twiddle_im(stageNum),din_re(stageNum),din_im(stageNum),din_vld,softReset],...
        [stageOut(stageNum),twiddleAddr(stageNum),dout_re(stageNum),dout_im(stageNum),dout_vld(stageNum),startOutS,endOutS],'Last_Stage');
    elseif blockInfo.outMode(1)&&blockInfo.BitReversedOutput
        startOutS=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name','startOutS');
        startOutS.SimulinkRate=dataRate;
        FFT_stageL=this.elabRADIX2FFT_KernelL(FFTImpl,blockInfo,inRate,stageIn(stageNum),twiddle_re(stageNum),twiddle_im(stageNum),din_re(stageNum),din_im(stageNum),din_vld,softReset,...
        stageOut(stageNum),twiddleAddr(stageNum),dout_re(stageNum),dout_im(stageNum),dout_vld(stageNum),startOutS,[]);
        pirelab.instantiateNetwork(FFTImpl,FFT_stageL,[stageOut(stageNum-1),twiddle_re(stageNum),twiddle_im(stageNum),din_re(stageNum),din_im(stageNum),din_vld,softReset],...
        [stageOut(stageNum),twiddleAddr(stageNum),dout_re(stageNum),dout_im(stageNum),dout_vld(stageNum),startOutS,[]],'Last_Stage');
    elseif blockInfo.outMode(2)&&blockInfo.BitReversedOutput
        endOutS=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name','endOutS');
        endOutS.SimulinkRate=dataRate;
        FFT_stageL=this.elabRADIX2FFT_KernelL(FFTImpl,blockInfo,inRate,stageIn(stageNum),twiddle_re(stageNum),twiddle_im(stageNum),din_re(stageNum),din_im(stageNum),din_vld,softReset,...
        stageOut(stageNum),twiddleAddr(stageNum),dout_re(stageNum),dout_im(stageNum),dout_vld(stageNum),[],endOutS);
        pirelab.instantiateNetwork(FFTImpl,FFT_stageL,[stageOut(stageNum-1),twiddle_re(stageNum),twiddle_im(stageNum),din_re(stageNum),din_im(stageNum),din_vld,softReset],...
        [stageOut(stageNum),twiddleAddr(stageNum),dout_re(stageNum),dout_im(stageNum),dout_vld(stageNum),[],endOutS],'Last_Stage');
    else
        FFT_stageL=this.elabRADIX2FFT_KernelL(FFTImpl,blockInfo,inRate,stageIn(stageNum),twiddle_re(stageNum),twiddle_im(stageNum),din_re(stageNum),din_im(stageNum),din_vld,softReset,...
        stageOut(stageNum),twiddleAddr(stageNum),dout_re(stageNum),dout_im(stageNum),dout_vld(stageNum),[],[]);
        pirelab.instantiateNetwork(FFTImpl,FFT_stageL,[stageOut(stageNum-1),twiddle_re(stageNum),twiddle_im(stageNum),din_re(stageNum),din_im(stageNum),din_vld,softReset],...
        [stageOut(stageNum),twiddleAddr(stageNum),dout_re(stageNum),dout_im(stageNum),dout_vld(stageNum),[],[]],'Last_Stage');
    end




    if~blockInfo.BitReversedOutput
        din_re=dout_re(stageNum);
        din_im=dout_im(stageNum);
        din_vld=dout_vld(stageNum);
        stageNum=stageNum+1;
        dout_re(stageNum)=FFTImpl.addSignal2('Type',din_re.Type,'Name',['dout_re',num2str(stageNum)]);
        dout_re(stageNum).SimulinkRate=dataRate;
        dout_im(stageNum)=FFTImpl.addSignal2('Type',din_re.Type,'Name',['dout_im',num2str(stageNum)]);
        dout_im(stageNum).SimulinkRate=dataRate;
        dout_vld(stageNum)=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name',['dout_vld',num2str(stageNum)]);
        dout_vld(stageNum).SimulinkRate=dataRate;
        if blockInfo.outMode(1)&&blockInfo.outMode(2)
            startOutS=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name','startOutS');
            startOutS.SimulinkRate=dataRate;
            endOutS=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name','endOutS');
            endOutS.SimulinkRate=dataRate;
            FFT_bitNatural=this.elabRADIX2FFT_bitNatural(FFTImpl,blockInfo,inRate,din_re,din_im,din_vld,softReset,...
            dout_re(stageNum),dout_im(stageNum),dout_vld(stageNum),startOutS,endOutS);
            pirelab.instantiateNetwork(FFTImpl,FFT_bitNatural,[din_re,din_im,din_vld,softReset],...
            [dout_re(stageNum),dout_im(stageNum),dout_vld(stageNum),startOutS,endOutS],'NaturalOrder_Stage');
        elseif blockInfo.outMode(1)
            startOutS=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name','startOutS');
            startOutS.SimulinkRate=dataRate;

            FFT_bitNatural=this.elabRADIX2FFT_bitNatural(FFTImpl,blockInfo,inRate,din_re,din_im,din_vld,softReset,...
            dout_re(stageNum),dout_im(stageNum),dout_vld(stageNum),startOutS,[]);
            pirelab.instantiateNetwork(FFTImpl,FFT_bitNatural,[din_re,din_im,din_vld,softReset],...
            [dout_re(stageNum),dout_im(stageNum),dout_vld(stageNum),startOutS,[]],'NaturalOrder_Stage');
        elseif blockInfo.outMode(2)
            endOutS=FFTImpl.addSignal2('Type',pir_boolean_t(),'Name','endOutS');
            endOutS.SimulinkRate=dataRate;
            FFT_bitNatural=this.elabRADIX2FFT_bitNatural(FFTImpl,blockInfo,inRate,din_re,din_im,din_vld,softReset,...
            dout_re(stageNum),dout_im(stageNum),dout_vld(stageNum),[],endOutS);
            pirelab.instantiateNetwork(FFTImpl,FFT_bitNatural,[din_re,din_im,din_vld,softReset],...
            [dout_re(stageNum),dout_im(stageNum),dout_vld(stageNum),[],endOutS],'NaturalOrder_Stage');
        else
            FFT_bitNatural=this.elabRADIX2FFT_bitNatural(FFTImpl,blockInfo,inRate,din_re,din_im,din_vld,softReset,...
            dout_re(stageNum),dout_im(stageNum),dout_vld(stageNum),[],[]);
            pirelab.instantiateNetwork(FFTImpl,FFT_bitNatural,[din_re,din_im,din_vld,softReset],...
            [dout_re(stageNum),dout_im(stageNum),dout_vld(stageNum),[],[]],'NaturalOrder_Stage');
        end
    end





    if blockInfo.inverseFFT
        dout_tmp=dout_re(stageNum);
        dout_re(stageNum)=dout_im(stageNum);
        dout_im(stageNum)=dout_tmp;
    end




    dout_cmplx=FFTImpl.addSignal2('Type',dataOut.Type,'Name','dout_cmplx');
    dout_cmplx.SimulinkRate=dataRate;
    pirelab.getRealImag2Complex(FFTImpl,[dout_re(stageNum),dout_im(stageNum)],dout_cmplx);
    pirelab.getWireComp(FFTImpl,dout_cmplx,outsignals(1));
    if blockInfo.outMode(1)&&blockInfo.outMode(2)
        pirelab.getWireComp(FFTImpl,startOutS,outsignals(2));
        pirelab.getWireComp(FFTImpl,endOutS,outsignals(3));
        pirelab.getWireComp(FFTImpl,dout_vld(stageNum),outsignals(4));
    elseif blockInfo.outMode(1)
        pirelab.getWireComp(FFTImpl,startOutS,outsignals(2));
        pirelab.getWireComp(FFTImpl,dout_vld(stageNum),outsignals(3));
    elseif blockInfo.outMode(2)
        pirelab.getWireComp(FFTImpl,endOutS,outsignals(2));
        pirelab.getWireComp(FFTImpl,dout_vld(stageNum),outsignals(3));
    else
        pirelab.getWireComp(FFTImpl,dout_vld(stageNum),outsignals(2));
    end
