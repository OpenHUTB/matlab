function hNewtonNet=getRecipNewtonRsqrtBasedNetwork(topNet,hInSignals,hOutSignals,newtonInfo)





















    hNewtonNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name',newtonInfo.networkName,...
    'InportNames',{'din'},...
    'InportTypes',[hInSignals(1).Type],...
    'InportRates',[hInSignals(1).SimulinkRate],...
    'OutportNames',{'dout'},...
    'OutportTypes',[hOutSignals(1).Type]);


    din=hNewtonNet.PirInputSignals(1);
    dout=hNewtonNet.PirOutputSignals(1);


    pirelab.getAnnotationComp(hNewtonNet,'anno','Reciprocal Implementation using RecipSqrt Newton Method');


    inputType=din.Type;
    outputType=dout.Type;
    ufix1Type=pir_ufixpt_t(1,0);


    inSigned=inputType.Signed;
    inputWL=inputType.WordLength;
    inputFL=-inputType.FractionLength;
    outSigned=outputType.Signed;
    outputWL=outputType.WordLength;
    outputFL=-outputType.FractionLength;


    rndMode=newtonInfo.rndMode;
    satMode=newtonInfo.satMode;
    ufix1_in=~inSigned&&(inputWL==1);
    sfix2_in=inSigned&&(inputWL==2);
    ufix1_out=~outSigned&&(outputWL==1);
    sfix2_out=outSigned&&(outputWL==2);
    if(ufix1_in||sfix2_in||ufix1_out||sfix2_out)
        hdlarch.newton.handleReciprocalSpecialCase(hNewtonNet,...
        din,dout,rndMode,satMode,'recip');
        return;
    end


    if inSigned

        din_usType=pir_ufixpt_t(inputWL,-inputFL);


        din_neg=hNewtonNet.addSignal(inputType,'din_neg');
        din_sel=hNewtonNet.addSignal(ufix1Type,'din_sel');
        din_mux=hNewtonNet.addSignal(inputType,'din_mux');
        din_dtc=hNewtonNet.addSignal(din_usType,'din_dtc');
        din_abs=hNewtonNet.addSignal(din_usType,'din_abs');


        oType_ex=pirelab.getTypeInfoAsFi(inputType,'Nearest','Saturate');
        umComp=pireml.getUnaryMinusComp(hNewtonNet,din,din_neg,oType_ex);
        umComp.addComment('Turn signed input into unsigned input');
        pireml.getCompareToValueComp(hNewtonNet,din,din_sel,'<',0);
        pireml.getSwitchComp(hNewtonNet,[din_sel,din_neg,din],din_mux);
        pireml.getDTCComp(hNewtonNet,din_mux,din_dtc);


        d1Comp=pireml.getUnitDelayComp(hNewtonNet,din_dtc,din_abs,'din_reg');
        d1Comp.addComment('Pipeline register');
    else
        din_abs=din;
    end




    rsqrtoutType=hdlarch.newton.getNewtonSqrtType(din_abs);


    rsnewtonInfo=newtonInfo;
    rsnewtonInfo.rndMode='Nearest';
    rsnewtonInfo.satMode='Saturate';
    rsqrt_out=hNewtonNet.addSignal(rsqrtoutType,'rsqrt_out');
    hdlarch.newton.getRecipSqrtNewtonComp(hNewtonNet,din_abs,rsqrt_out,rsnewtonInfo);


    rsqrt_outp=hNewtonNet.addSignal(rsqrtoutType,'rsqrt_outp');
    d2Comp=pireml.getUnitDelayComp(hNewtonNet,rsqrt_out,rsqrt_outp,'rsqrt_out_reg');
    d2Comp.addComment('Pipeline register');


    tSignalIn=[rsqrt_outp,rsqrt_outp];
    if inSigned
        dout_usType=pir_ufixpt_t(outputWL,-outputFL);
    else
        dout_usType=outputType;
    end
    mul_out=hNewtonNet.addSignal(dout_usType,'mul_out');
    mulComp=pireml.getMulComp(hNewtonNet,tSignalIn,mul_out,'Nearest','Saturate','mul');
    mulComp.addComment('Multiply RecipSqrt result by itself');


    if inSigned


        mul_outp=hNewtonNet.addSignal(dout_usType,'mul_outp');
        d3Comp=pireml.getUnitDelayComp(hNewtonNet,mul_out,mul_outp,'mulout_reg');
        d3Comp.addComment('Pipeline register');


        din_selp=hNewtonNet.addSignal(ufix1Type,'din_selp');
        d3Comp=pireml.getIntDelayComp(hNewtonNet,din_sel,din_selp,newtonInfo.iterNum+5,'ds_reg');
        d3Comp.addComment('Pipeline registers');


        dout_dtc=hNewtonNet.addSignal(outputType,'dout_dtc');
        dout_neg=hNewtonNet.addSignal(outputType,'dout_neg');


        if outSigned
            dtcComp=pireml.getDTCComp(hNewtonNet,mul_outp,dout_dtc,'Nearest','Saturate');
            dtcComp.addComment('Add sign to output');
            oType_ex=pirelab.getTypeInfoAsFi(outputType,'Nearest','Saturate');
            pireml.getUnaryMinusComp(hNewtonNet,dout_dtc,dout_neg,oType_ex);
        else
            pireml.getWireComp(hNewtonNet,mul_outp,dout_dtc);
            pireml.getConstComp(hNewtonNet,dout_neg,0);
        end
        pireml.getSwitchComp(hNewtonNet,[din_selp,dout_neg,dout_dtc],dout);
    else
        pireml.getWireComp(hNewtonNet,mul_out,dout);
    end




