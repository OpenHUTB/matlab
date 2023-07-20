function elabHDLFilterBank(this,FFTImpl,blockInfo)









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
    if blockInfo.inMode(2)
        softReset=insignals(3);
        softReset.SimulinkRate=dataRate;
    else
        softReset=FFTImpl.addSignal2('Type',pir_boolean_t,'Name','softReset');
        softReset.SimulinkRate=dataRate;
        pirelab.getConstComp(FFTImpl,softReset,false);
    end

    DATA_SIGN=dataInType.issigned;
    DATA_WORDLENGTH=dataInType.wordsize;
    DATA_FRACTIONLENGTH=dataInType.binarypoint;
    DATA_VECSIZE=dataInType.dims;
    DATA_CMPLX=dataInType.iscomplex;

    blockInfo.InputDataIsReal=~DATA_CMPLX;
    if DATA_SIGN
        din_type=pir_fixpt_t(1,DATA_WORDLENGTH,DATA_FRACTIONLENGTH);
    else
        din_type=pir_fixpt_t(1,DATA_WORDLENGTH+1,DATA_FRACTIONLENGTH);
        DATA_WORDLENGTH=DATA_WORDLENGTH+1;
    end




    COEF_WORDLENGTH=DATA_WORDLENGTH;
    COEF_FRACTIONLENGTH=-(DATA_WORDLENGTH-1);
    blockInfo.COEF_WORDLENGTH=COEF_WORDLENGTH;
    blockInfo.COEF_FRACTIONLENGTH=COEF_FRACTIONLENGTH;








    dout_re=FFTImpl.addSignal2('Type',outsignals(1).Type,'Name','dout_re');
    dout_re.SimulinkRate=dataRate;
    dout_im=FFTImpl.addSignal2('Type',outsignals(1).Type,'Name','dout_im');
    dout_re.SimulinkRate=dataRate;
    if DATA_VECSIZE==1
        if DATA_CMPLX
            dout_cmplx=FFTImpl.addSignal2('Type',outsignals(1).Type,'Name','dout_cmplx');
            dout_cmplx.SimulinkRate=dataRate;
            pirelab.getRealImag2Complex(FFTImpl,[dout_re,dout_im],dout_cmplx);
        end
    else
        for inIndex=1:DATA_VECSIZE
            if DATA_CMPLX
                dout_cmplx(inIndex)=FFTImpl.addSignal2('Type',outsignals(1).Type.BaseType,'Name',['dout_cmplx_',int2str(inIndex)]);%#ok<*AGROW>
                dout_cmplx(inIndex).SimulinkRate=dataRate;
                pirelab.getRealImag2Complex(FFTImpl,[dout_re(inIndex),dout_im(inIndex)],dout_cmplx(inIndex));
            else
                pirelab.getRealImag2Complex(FFTImpl,[dout_re(inIndex),dout_im(inIndex)],dout_cmplx(inIndex));
            end
        end
    end

    if DATA_VECSIZE==1
        if DATA_CMPLX
            pirelab.getWireComp(FFTImpl,dout_cmplx,outsignals(1));
        else
            pirelab.getWireComp(FFTImpl,dataIn,outsignals(1));
        end
    else
        if DATA_CMPLX
            pirelab.getMuxComp(FFTImpl,dout_cmplx,outsignals(1));
        else

        end
    end

    pirelab.getWireComp(FFTImpl,din_vld,outsignals(2));












