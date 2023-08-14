function getNonRestoreReciprocalComp(hN,hInSignals,hOutSignals,reciprocalInfo)




    RinType=reciprocalInfo.denominatorTypeInfo.dType;
    RinWL=reciprocalInfo.denominatorTypeInfo.dWL;
    RinSign=reciprocalInfo.denominatorTypeInfo.dSign;
    ZinWL=reciprocalInfo.numeratorTypeInfo.zWL;
    fractiondiff=reciprocalInfo.fractiondiff;

    RoutType=hOutSignals.Type;
    RoutWL=RoutType.WordLength;
    RoutFL=-RoutType.FractionLength;


    if(~strcmpi(reciprocalInfo.OutType,'Inherit: Inherit via internal rule'))
        iterations=hInSignals(1).Type.BaseType.Wordlength+abs(fractiondiff);
    else
        iterations=RoutWL;
    end

    totalPipelinestages=iterations+4;

    pipelinestageArray=customPipelineStages(totalPipelinestages,reciprocalInfo.customLatency,reciprocalInfo.latencyStrategy);

    delayName1=sprintf('%s_reg',hInSignals(1).Name);
    In1_p=hN.addSignal(hInSignals(1).Type.BaseType,delayName1);

    if strcmpi(reciprocalInfo.pipeline,'on')
        pirelab.getIntDelayComp(hN,hInSignals(1),In1_p,pipelinestageArray(1),'Rin_p',0,0,0,[],0,0);
    else
        In1_p=hInSignals(1);
    end
    Name1=sprintf('%In1_dtc_reg',hInSignals(1).Name);
    In1_p_dtc=hN.addSignal(RinType,Name1);
    pirelab.getDTCComp(hN,In1_p,In1_p_dtc,'Floor','Wrap','RWV','In1_dtc');

    shiftName1=sprintf('%sshift_reg',hInSignals(1).Name);
    In1_p_shift=hN.addSignal(RinType,shiftName1);
    zWLNew=2*(ZinWL);
    if(~strcmpi(reciprocalInfo.OutType,'Inherit: Inherit via internal rule'))
        dWLNew=RinWL;
    else



        dWLNew=RoutWL;
    end
    if(~strcmpi(reciprocalInfo.OutType,'Inherit: Inherit via internal rule')&&fractiondiff<0)
        pirelab.getBitShiftComp(hN,In1_p_dtc,In1_p_shift,'sll',abs(fractiondiff),0,'Bit Shift');
    else
        In1_p_shift=In1_p_dtc;
    end


    if(RinSign)
        dNewType=hdlcoder.tp_sfixpt(dWLNew+1,0);
        zNewType=hdlcoder.tp_sfixpt(zWLNew,0);
    else

        dNewType=hdlcoder.tp_sfixpt(dWLNew+1+2,0);
        zNewType=hdlcoder.tp_sfixpt(zWLNew+2,0);
    end

    corrected_z_p=hN.addSignal(zNewType,'corrected_z_p');
    corrected_d=hN.addSignal(dNewType,'corrected_d');
    corrected_d_p=hN.addSignal(dNewType,'corrected_d_p');
    d_ext=hN.addSignal(dNewType,'d_ext');

    Rin_MSB=hN.addSignal(hdlcoder.tp_ufixpt(1,0),'Rin_MSB');
    pirelab.getDTCComp(hN,In1_p_shift,d_ext,'Floor','Wrap','SI','In1_dtc');
    pirelab.getBitSliceComp(hN,d_ext,Rin_MSB,dWLNew,dWLNew,'Bit Slice1');

    unary_minus_d=hN.addSignal(dNewType,'unary_minus_d');
    pirelab.getUnaryMinusComp(hN,d_ext,unary_minus_d,'Wrap','Unary Minus');

    constant_z=hN.addSignal(zNewType,'constant_z');
    if(fractiondiff<0)
        zData=1;
    else
        zData=2^(fractiondiff);
    end
    pirelab.getConstComp(hN,constant_z,zData,'zData');


    pirelab.getSwitchComp(hN,[unary_minus_d,d_ext],corrected_d,Rin_MSB,'Switch1','~=',0,'Floor','Wrap');

    if strcmpi(reciprocalInfo.pipeline,'on')
        pirelab.getIntDelayComp(hN,constant_z,corrected_z_p,pipelinestageArray(2),'corrected_z_p',0,0,0,[],0,0);
        pirelab.getIntDelayComp(hN,corrected_d,corrected_d_p,pipelinestageArray(2),'corrected_d_p',0,0,0,[],0,0);
    else
        corrected_z_p=constant_z;
        corrected_d_p=corrected_d;
    end


    signFlag_p=hN.addSignal(hdlcoder.tp_ufixpt(1,0),'signFlag_p');
    pStageSum=sum(pipelinestageArray(2:end-1));

    if strcmpi(reciprocalInfo.pipeline,'on')
        pirelab.getIntDelayComp(hN,Rin_MSB,signFlag_p,pStageSum,'signFlag_p',0,0,0,[],0,0);
    else
        signFlag_p=Rin_MSB;
    end


    IteratorInSigs=[corrected_z_p,corrected_d_p];
    for stageNum=1:iterations

        r=hN.addSignal(zNewType,sprintf('r%d',stageNum));
        d=hN.addSignal(dNewType,sprintf('d%d',stageNum));
        IteratorOutSigs=[r,d];

        pireml.getDivNonRestoreIteratorComp(hN,IteratorInSigs,IteratorOutSigs,uint8(stageNum));

        r_p=hN.addSignal(zNewType,sprintf('r%d_p',stageNum));
        d_p=hN.addSignal(dNewType,sprintf('d%d_p',stageNum));
        if strcmpi(reciprocalInfo.pipeline,'on')
            pirelab.getIntDelayComp(hN,r,r_p,pipelinestageArray(2+stageNum),'r_reg');
            pirelab.getIntDelayComp(hN,d,d_p,pipelinestageArray(2+stageNum),'d_reg');
        else
            r_p=r;
            d_p=d;
        end

        IteratorInSigs=[r_p,d_p];
    end





    QWLTemp=dWLNew;

    qtemp=hN.addSignal(hdlcoder.tp_ufixpt(QWLTemp,0),'qTemp');
    pirelab.getBitSliceComp(hN,r_p,qtemp,QWLTemp-1,0,'Bit Slice1');


    if(RinSign)
        qtempExt=hN.addSignal(hdlcoder.tp_sfixpt(QWLTemp+1,0),'qtempExt');
        qtempExt_p=hN.addSignal(hdlcoder.tp_sfixpt(QWLTemp+1,0),'qtempExt_p');
        pirelab.getDTCComp(hN,qtemp,qtempExt);
        if strcmpi(reciprocalInfo.pipeline,'on')
            pirelab.getIntDelayComp(hN,qtempExt,qtempExt_p,pipelinestageArray(end-1),'qtempExt_p');
        else
            qtempExt_p=qtempExt;
        end
        postCorrectionInSignals=[qtempExt_p,signFlag_p];
        if((~strcmpi(reciprocalInfo.OutType,'Inherit: Inherit via internal rule')))
            if(qtempExt_p.Type.WordLength<RoutWL)
                qtempPost=hN.addSignal(hdlcoder.tp_sfixpt(RoutWL+1,0),'qtempPost');
                postCorrectionOutSignal=qtempPost;
                RoutWL=RoutWL+1;
            else
                qtempPost=hN.addSignal(hdlcoder.tp_sfixpt(QWLTemp+1,0),'qtempPost');
                postCorrectionOutSignal=qtempPost;
                RoutWL=QWLTemp+1;
            end

            pireml.getDivPostCorrectionComp(hN,postCorrectionInSignals,postCorrectionOutSignal);
        else
            qtempPost=hN.addSignal(hdlcoder.tp_sfixpt(QWLTemp,0),'qtempPost');
            postCorrectionOutSignal=qtempPost;

            pireml.getDivPostCorrectionComp(hN,postCorrectionInSignals,postCorrectionOutSignal);
        end
    else
        RoutWL=QWLTemp;
        qtempExt_p_temp=hN.addSignal(hdlcoder.tp_ufixpt(QWLTemp,0),'qtempExt_p');
        if strcmpi(reciprocalInfo.pipeline,'on')
            pirelab.getIntDelayComp(hN,qtemp,qtempExt_p_temp,pipelinestageArray(end-1),'qtempExt_p');
        else
            qtempExt_p_temp=qtemp;
        end
        if((~strcmpi(reciprocalInfo.OutType,'Inherit: Inherit via internal rule')))
            qtempWL=qtempExt_p_temp.Type.WordLength;
            outWL=hOutSignals.Type.WordLength;
            if((qtempWL<outWL))
                RoutWL=outWL+1;

                if(hOutSignals.Type.Signed==1)
                    MaxValue=2^(outWL-1)-1;
                    qtempExt_p_temp_ext2=hN.addSignal(hdlcoder.tp_sfixpt(qtempWL+1,0),'qtempExt_p_temp');
                    qoutDTC_temp=hN.addSignal(hdlcoder.tp_sfixpt(outWL,0),'qoutDTC_temp');
                    ConstantSignalMaxMin=hN.addSignal(hdlcoder.tp_sfixpt(outWL,0),'ConstantSignalMaxMin');
                    qtempExt_p=hN.addSignal(hdlcoder.tp_sfixpt(outWL,0),'qoutDTC');
                else
                    MaxValue=2^(outWL)-1;
                    qtempExt_p_temp_ext2=hN.addSignal(hdlcoder.tp_ufixpt(qtempWL+1,0),'qtempExt_p_temp');
                    qoutDTC_temp=hN.addSignal(hdlcoder.tp_ufixpt(outWL,0),'qoutDTC_temp');
                    ConstantSignalMaxMin=hN.addSignal(hdlcoder.tp_ufixpt(outWL,0),'ConstantSignalMaxMin');
                    qtempExt_p=hN.addSignal(hdlcoder.tp_ufixpt(outWL,0),'qoutDTC');
                end
            else
                MaxValue=2^(qtempWL)-1;
                qtempExt_p_temp_ext2=hN.addSignal(hdlcoder.tp_ufixpt(qtempWL+1,0),'qtempExt_p_temp');
                qoutDTC_temp=hN.addSignal(hdlcoder.tp_ufixpt(qtempWL,0),'qoutDTC_temp');
                ConstantSignalMaxMin=hN.addSignal(hdlcoder.tp_ufixpt(qtempWL,0),'ConstantSignalMaxMin');
                qtempExt_p=hN.addSignal(hdlcoder.tp_ufixpt(qtempWL,0),'qoutDTC');

            end
            qV=fi(2^(qtempWL)-1,1,qtempWL+1,0);

            qtempExt_p_temp_ext=hN.addSignal(hdlcoder.tp_ufixpt(qtempWL+1,0),'qtempExt_p_temp');

            isEqualToMaxMin=hN.addSignal(hdlcoder.tp_ufixpt(1,0),'isEqualToMaxMin');

            pirelab.getDTCComp(hN,qtempExt_p_temp,qtempExt_p_temp_ext,'Floor','Saturate','SI','Data Type Conversion1');
            pirelab.getDTCComp(hN,qtempExt_p_temp_ext,qtempExt_p_temp_ext2,'Floor','Saturate','SI','Data Type Conversion1');
            pirelab.getDTCComp(hN,qtempExt_p_temp_ext2,qoutDTC_temp,'Floor','Saturate','SI','Data Type Conversion1');
            pirelab.getConstComp(hN,ConstantSignalMaxMin,MaxValue,'ConstantSignalMaxMin');
            pirelab.getCompareToValueComp(hN,qoutDTC_temp,isEqualToMaxMin,'==',qV,sprintf('Compare\nTo Constant'),0);
            pirelab.getSwitchComp(hN,[ConstantSignalMaxMin,qoutDTC_temp],qtempExt_p,isEqualToMaxMin,'Switch1','~=',0,'Floor','Wrap');
        else
            qtempExt_p=qtempExt_p_temp;
        end

    end



    if strcmpi(reciprocalInfo.latencyStrategy,'MAX')
        constantValue=iterations+1+4;
        max=true;
        custom=false;
    elseif strcmpi(reciprocalInfo.latencyStrategy,'CUSTOM')
        constantValue=reciprocalInfo.customLatency+1;
        custom=true;
        max=false;
    else
        custom=false;
        max=false;
    end

    isLatencyNeeded=max||(custom&&(reciprocalInfo.customLatency>0));

    if strcmpi(reciprocalInfo.pipeline,'on')
        if(isLatencyNeeded)
            boolType=hdlcoder.tp_ufixpt(1,0);
            trueFlag=hN.addSignal(boolType,'trueFlag');
            trueFlag.SimulinkRate=hInSignals(1).SimulinkRate;
            initFlagDelay=hN.addSignal(boolType,'initFlagDelay');
            initFlagDelayData=hN.addSignal(hdlcoder.tp_ufixpt(ceil(log2(constantValue))+1,0),'initFlagDelayData');
            initFlagenable=hN.addSignal(boolType,'initFlagDelayData');
            initAddType=hdlcoder.tp_ufixpt(ceil(log2(constantValue))+1,0);
            initFlagAddDataOutDelay=hN.addSignal(initAddType,'initFlagAddDataOutDelay');
            initFlagAddDataOut=hN.addSignal(initAddType,'initFlagAddDataOut');
            latencyValueConstantSignal=hN.addSignal(initAddType,'latencyValueConstantSignal');
            if(RinSign)
                ConstantSignal=hN.addSignal(hdlcoder.tp_sfixpt(RoutWL,0),'ConstantSignal');
            else
                ConstantSignal=hN.addSignal(hdlcoder.tp_ufixpt(RoutWL,0),'ConstantSignal');
            end
            isCountReachedFlag=hN.addSignal(boolType,'isCountReachedFlag');
            pirelab.getConstComp(hN,trueFlag,1,'trueFlag');

            pirelab.getConstComp(hN,ConstantSignal,0,'ConstantSignal');
            pirelab.getDTCComp(hN,initFlagenable,initFlagDelayData);
            pirelab.getLogicComp(hN,[initFlagDelay,trueFlag],initFlagenable,'and','andLogic');
            pirelab.getAddComp(hN,[initFlagDelayData,initFlagAddDataOutDelay],initFlagAddDataOut,'Floor','Wrap','Add',hdlcoder.tp_ufixpt(ceil(log2(iterations+1+4)),0),'++');
            pirelab.getUnitDelayComp(hN,initFlagAddDataOut,initFlagAddDataOutDelay,'initFlagAddDataOutDelay',1);
            if(custom&&(reciprocalInfo.customLatency==1||reciprocalInfo.customLatency==2))
                pirelab.getConstComp(hN,latencyValueConstantSignal,constantValue-1,'latencyValue');
            else
                pirelab.getConstComp(hN,latencyValueConstantSignal,constantValue-2,'latencyValue');
            end
            pirelab.getRelOpComp(hN,[initFlagAddDataOut,latencyValueConstantSignal],isCountReachedFlag,'<=',0,sprintf('Relational\nOperator'));
            pirelab.getUnitDelayComp(hN,isCountReachedFlag,initFlagDelay,'initFlagDelay');
        end
    end
    if(RinSign)
        qtempInit=hN.addSignal(hdlcoder.tp_sfixpt(RoutWL,0),'qtempPost');
        qtempInitOutDTC=hN.addSignal(hdlcoder.tp_sfixpt(RoutWL,-RoutFL),'qtempPost');

        postCorrectionSig2=postCorrectionOutSignal;

        if strcmpi(reciprocalInfo.pipeline,'on')
            if(isLatencyNeeded&&(~(transformnfp.needNoInitialize())))
                pirelab.getSwitchComp(hN,[ConstantSignal,postCorrectionSig2],qtempInit,isCountReachedFlag,'Switch1','~=',0,'Floor','Wrap');
            else
                qtempInit=postCorrectionSig2;
            end
        else
            qtempInit=postCorrectionSig2;
        end
    else
        qtempInit=hN.addSignal(hdlcoder.tp_ufixpt(RoutWL,0),'qtempPost');
        qtempInitOutDTC=hN.addSignal(hdlcoder.tp_ufixpt(RoutWL,-RoutFL),'qtempPost');
        if strcmpi(reciprocalInfo.pipeline,'on')
            if(isLatencyNeeded&&(~(transformnfp.needNoInitialize())))
                pirelab.getSwitchComp(hN,[ConstantSignal,qtempExt_p],qtempInit,isCountReachedFlag,'Switch1','~=',0,'Floor','Wrap');
            else
                qtempInit=qtempExt_p;
            end
        else
            qtempInit=qtempExt_p;
        end
    end
    pirelab.getDTCComp(hN,qtempInit,qtempInitOutDTC,'Floor','Saturate','SI','Data Type Conversion1');
    qoutDTC=hN.addSignal(RoutType,'qoutDTC');

    pirelab.getDTCComp(hN,qtempInitOutDTC,qoutDTC,'Floor','Saturate','SI','Data Type Conversion1');
    if strcmpi(reciprocalInfo.pipeline,'on')

        pirelab.getIntDelayComp(hN,qoutDTC,hOutSignals,pipelinestageArray(end),'q');
    else
        pirelab.getWireComp(hN,qoutDTC,hOutSignals,'q');
    end
end
function pipelinestageArray=customPipelineStages(totalPipelineStages,latency,latencyStrategy)

    pipelinestageArray=zeros(1,totalPipelineStages);
    if(strcmpi(latencyStrategy,'MAX'))
        pipelinestageArray=ones(1,totalPipelineStages);
    elseif(strcmpi(latencyStrategy,'CUSTOM'))


        if(latency~=0)



            if(latency==1)
                pipelinestageArray(end-(end-3))=1;
            elseif(latency==2)
                if(totalPipelineStages~=6)


                    pipelinestageArray(3)=1;
                    pipelinestageArray(end-3)=1;

                else

                    pipelinestageArray(2)=1;
                    pipelinestageArray(end-3)=1;
                end

            else


                k=ceil(totalPipelineStages/latency);

                j=1;
                temp=1;

                for i=1:latency
                    if(latency>1)
                        if(i==latency)

                            pipelinestageArray(end)=1;
                        else
                            pipelinestageArray(j)=1;


                            if(j<totalPipelineStages-k)
                                j=j+k;
                            else

                                j=temp+1;

                                temp=temp+1;
                            end
                        end

                    else
                        pipelinestageArray(j)=1;
                    end

                end
            end
        end
    end
end




