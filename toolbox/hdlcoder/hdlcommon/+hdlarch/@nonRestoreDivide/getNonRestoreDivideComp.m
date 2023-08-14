function getNonRestoreDivideComp(hN,hInSignals,hOutSignals,divideInfo)




    zType=divideInfo.numeratorTypeInfo.zType;
    zWL=divideInfo.numeratorTypeInfo.zWL;
    zSign=divideInfo.numeratorTypeInfo.zSign;
    dType=divideInfo.denominatorTypeInfo.dType;
    dWL=divideInfo.denominatorTypeInfo.dWL;
    dSign=divideInfo.denominatorTypeInfo.dSign;
    QWL=divideInfo.quotientTypeInfo.QWL;
    QFL=divideInfo.quotientTypeInfo.QFL;
    fractiondiff=divideInfo.fractiondiff;



    if((zSign==1&&dSign==0)||zSign==0&&dSign==1)
        iterations=QWL+1;
    else
        iterations=QWL;
    end


    totalPipelinestages=iterations+4;

    pipelinestageArray=customPipelineStages(totalPipelinestages,divideInfo.customLatency,divideInfo.latencyStrategy);

    delayName1=sprintf('%s_reg',hInSignals(1).Name);
    delayName2=sprintf('%s_reg',hInSignals(2).Name);
    In1_p=hN.addSignal(hInSignals(1).Type,delayName1);
    In2_p=hN.addSignal(hInSignals(2).Type,delayName2);
    if strcmpi(divideInfo.pipeline,'on')
        pirelab.getIntDelayComp(hN,hInSignals(1),In1_p,pipelinestageArray(1),'z_p',0,0,0,[],0,0);
        pirelab.getIntDelayComp(hN,hInSignals(2),In2_p,pipelinestageArray(1),'d_p',0,0,0,[],0,0);
    else
        In1_p=hInSignals(1);
        In2_p=hInSignals(2);
    end


    Name1=sprintf('%In1_dtc_reg',hInSignals(1).Name);
    In1_p_dtc=hN.addSignal(zType,Name1);
    pirelab.getDTCComp(hN,In1_p,In1_p_dtc,'Floor','Wrap','RWV','In1_dtc');
    Name2=sprintf('%In2_dtc_reg',hInSignals(1).Name);
    In2_p_dtc=hN.addSignal(dType,Name2);
    pirelab.getDTCComp(hN,In2_p,In2_p_dtc,'Floor','Wrap','RWV','In2_dtc');
    if(~strcmpi(divideInfo.OutType,'Inherit: Inherit via internal rule'))
        if(fractiondiff<0)

            shiftName1=sprintf('%sshift_reg',hInSignals(2).Name);
            In2_p_shift=hN.addSignal(dType,shiftName1);
            pirelab.getBitShiftComp(hN,In2_p_dtc,In2_p_shift,'sll',abs(fractiondiff),0,'Bit Shift');
            In1_p_shift=In1_p_dtc;
        elseif(fractiondiff>0)

            shiftName1=sprintf('%sshift_reg',hInSignals(1).Name);
            In1_p_shift=hN.addSignal(zType,shiftName1);
            pirelab.getBitShiftComp(hN,In1_p_dtc,In1_p_shift,'sll',(fractiondiff),0,'Bit Shift');
            In2_p_shift=In2_p_dtc;
        else
            In1_p_shift=In1_p_dtc;
            In2_p_shift=In2_p_dtc;
        end
    else
        In1_p_shift=In1_p_dtc;
        In2_p_shift=In2_p_dtc;
    end
    z_MSB=hN.addSignal(hdlcoder.tp_ufixpt(1,0),'z_MSB');
    d_MSB=hN.addSignal(hdlcoder.tp_ufixpt(1,0),'d_MSB');
    if(zSign||dSign)


        if(zSign==0&&dSign==1)
            In1_dtc=hN.addSignal(hdlcoder.tp_sfixpt(zWL+1,0),'In1_dtc');
            pirelab.getDTCComp(hN,In1_p_shift,In1_dtc,'Floor','Wrap','SI','In1_dtc');
            pirelab.getBitSliceComp(hN,In1_dtc,z_MSB,zWL,zWL,'Bit Slice1');
            pirelab.getBitSliceComp(hN,In2_p_shift,d_MSB,dWL-1,dWL-1,'Bit Slice2');


        elseif(zSign==1&&dSign==0)
            In2_dtc=hN.addSignal(hdlcoder.tp_sfixpt(dWL+1,0),'In2_dtc');
            pirelab.getDTCComp(hN,In2_p_shift,In2_dtc,'Floor','Wrap','SI','In2_dtc');
            pirelab.getBitSliceComp(hN,In1_p_shift,z_MSB,zWL-1,zWL-1,'Bit Slice1');
            pirelab.getBitSliceComp(hN,In2_dtc,d_MSB,dWL,dWL,'Bit Slice2');

        else

            pirelab.getBitSliceComp(hN,In1_p_shift,z_MSB,zWL-1,zWL-1,'Bit Slice1');
            pirelab.getBitSliceComp(hN,In2_p_shift,d_MSB,dWL-1,dWL-1,'Bit Slice2');
        end


        signFlag=hN.addSignal(hdlcoder.tp_ufixpt(1,0),'isSignsDiffer');
        pirelab.getLogicComp(hN,[z_MSB,d_MSB],signFlag,'xor',sprintf('Logical\nOperator'));

    end


    if((zSign==1&&dSign==0)||zSign==0&&dSign==1)
        zWLNew=2*(QWL+1);
        dWLNew=QWL+1;
    else
        zWLNew=2*QWL;
        dWLNew=QWL;
    end

    if(zSign||dSign)
        dNewType=hdlcoder.tp_sfixpt(dWLNew+1,0);
        zNewType=hdlcoder.tp_sfixpt(zWLNew,0);
    else

        dNewType=hdlcoder.tp_sfixpt(dWLNew+1+2,0);
        zNewType=hdlcoder.tp_sfixpt(zWLNew+2,0);
    end
    corrected_z_p=hN.addSignal(zNewType,'corrected_z_p');
    corrected_d_p=hN.addSignal(dNewType,'corrected_d_p');
    if(zSign||dSign)

        preCorrectionOutSig2=hN.addSignal(dNewType,'corrected_d');
        preCorrectionOutSig1=hN.addSignal(zNewType,'corrected_z');

        if(zSign==0)
            preCorrectionInSigs=[In1_dtc,In2_p,z_MSB,d_MSB];
        elseif(dSign==0)
            preCorrectionInSigs=[In1_p_shift,In2_dtc,z_MSB,d_MSB];
        else
            preCorrectionInSigs=[In1_p_shift,In2_p_shift,z_MSB,d_MSB];
        end

        preCorrectionOutSigs=[preCorrectionOutSig1,preCorrectionOutSig2];
        pireml.getDivPreCorrectionComp(hN,preCorrectionInSigs,preCorrectionOutSigs);
        if strcmpi(divideInfo.pipeline,'on')

            pirelab.getIntDelayComp(hN,preCorrectionOutSig1,corrected_z_p,pipelinestageArray(2),'corrected_z_p',0,0,0,[],0,0);
            pirelab.getIntDelayComp(hN,preCorrectionOutSig2,corrected_d_p,pipelinestageArray(2),'corrected_d_p',0,0,0,[],0,0);
        else
            corrected_z_p=preCorrectionOutSig1;
            corrected_d_p=preCorrectionOutSig2;
        end
    else

        In1_dtc=hN.addSignal(zNewType,'In1_dtc');
        pirelab.getDTCComp(hN,In1_p_shift,In1_dtc,'Floor','Wrap','SI','In1_dtc');

        In2_dtc=hN.addSignal(dNewType,'In2_dtc');
        pirelab.getDTCComp(hN,In2_p_shift,In2_dtc,'Floor','Wrap','SI','In2_dtc');
        if strcmpi(divideInfo.pipeline,'on')
            pirelab.getIntDelayComp(hN,In1_dtc,corrected_z_p,pipelinestageArray(2),'corrected_z_p',0,0,0,[],0,0);
            pirelab.getIntDelayComp(hN,In2_dtc,corrected_d_p,pipelinestageArray(2),'corrected_d_p',0,0,0,[],0,0);
        else
            corrected_z_p=In1_dtc;
            corrected_d_p=In2_dtc;
        end
    end

    pStageSum=sum(pipelinestageArray(2:end-1));

    if(zSign||dSign)

        signFlag_p=hN.addSignal(hdlcoder.tp_ufixpt(1,0),'signFlag_p');
        if strcmpi(divideInfo.pipeline,'on')
            pirelab.getIntDelayComp(hN,signFlag,signFlag_p,pStageSum,'signFlag_p',0,0,0,[],0,0);
        else
            signFlag_p=signFlag;
        end
    end


    IteratorInSigs=[corrected_z_p,corrected_d_p];
    for stageNum=1:iterations

        r=hN.addSignal(zNewType,sprintf('r%d',stageNum));
        d=hN.addSignal(dNewType,sprintf('d%d',stageNum));
        IteratorOutSigs=[r,d];

        pireml.getDivNonRestoreIteratorComp(hN,IteratorInSigs,IteratorOutSigs,uint8(stageNum));

        r_p=hN.addSignal(zNewType,sprintf('r%d_p',stageNum));
        d_p=hN.addSignal(dNewType,sprintf('d%d_p',stageNum));
        if strcmpi(divideInfo.pipeline,'on')
            pirelab.getIntDelayComp(hN,r,r_p,pipelinestageArray(2+stageNum),'r_reg');
            pirelab.getIntDelayComp(hN,d,d_p,pipelinestageArray(2+stageNum),'d_reg');
        else
            r_p=r;
            d_p=d;
        end

        IteratorInSigs=[r_p,d_p];
    end




    if((zSign==1&&dSign==0)||zSign==0&&dSign==1)

        QWLTemp=QWL+1;
    else
        QWLTemp=QWL;
    end

    qtemp=hN.addSignal(hdlcoder.tp_ufixpt(QWLTemp,0),'qTemp');
    pirelab.getBitSliceComp(hN,r_p,qtemp,QWLTemp-1,0,'Bit Slice1');


    if(zSign||dSign)
        qtempExt=hN.addSignal(hdlcoder.tp_sfixpt(QWLTemp+1,0),'qtempExt');
        qtempExt_p=hN.addSignal(hdlcoder.tp_sfixpt(QWLTemp+1,0),'qtempExt_p');
        pirelab.getDTCComp(hN,qtemp,qtempExt);
        if strcmpi(divideInfo.pipeline,'on')
            pirelab.getIntDelayComp(hN,qtempExt,qtempExt_p,pipelinestageArray(end-1),'qtempExt_p');
        else
            qtempExt_p=qtempExt;
        end
        postCorrectionInSignals=[qtempExt_p,signFlag_p];
        if((~strcmpi(divideInfo.OutType,'Inherit: Inherit via internal rule')))
            if(qtempExt_p.Type.WordLength<hOutSignals.Type.WordLength)
                qtempPost=hN.addSignal(hdlcoder.tp_sfixpt(hOutSignals.Type.WordLength+1,0),'qtempPost');
                QWL=hOutSignals.Type.WordLength+1;
                postCorrectionOutSignal=qtempPost;


            else
                qtempPost=hN.addSignal(hdlcoder.tp_sfixpt(QWLTemp+1,0),'qtempPost');
                QWL=QWLTemp+1;
                postCorrectionOutSignal=qtempPost;
            end
            pireml.getDivPostCorrectionComp(hN,postCorrectionInSignals,postCorrectionOutSignal);
        else
            qtempPost=hN.addSignal(hdlcoder.tp_sfixpt(QWLTemp,0),'qtempPost');
            postCorrectionOutSignal=qtempPost;

            pireml.getDivPostCorrectionComp(hN,postCorrectionInSignals,postCorrectionOutSignal);
        end


    else








        qtempExt_p_temp=hN.addSignal(hdlcoder.tp_ufixpt(QWL,0),'qtempExt_p_temp');
        if strcmpi(divideInfo.pipeline,'on')
            pirelab.getIntDelayComp(hN,qtemp,qtempExt_p_temp,pipelinestageArray(end-1),'qtempExt_p');
        else
            qtempExt_p_temp=qtemp;
        end
        if((~strcmpi(divideInfo.OutType,'Inherit: Inherit via internal rule')))
            qtempWL=qtempExt_p_temp.Type.WordLength;
            outWL=hOutSignals.Type.WordLength;
            if((qtempWL<outWL))
                QWL=outWL+1;

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




    if strcmpi(divideInfo.latencyStrategy,'MAX')
        constantValue=iterations+1+4;
        max=true;
        custom=false;
    elseif strcmpi(divideInfo.latencyStrategy,'CUSTOM')
        constantValue=divideInfo.customLatency+1;
        max=false;
        custom=true;
    else
        max=false;
        custom=false;

    end


    isLatencyNeeded=max||(custom&&(divideInfo.customLatency>0));

    if strcmpi(divideInfo.pipeline,'on')
        if(isLatencyNeeded)
            boolType=hdlcoder.tp_ufixpt(1,0);
            trueFlag=hN.addSignal(boolType,'trueFlag');
            trueFlag.SimulinkRate=hInSignals(1).SimulinkRate;
            initFlagDelay=hN.addSignal(boolType,'initFlagDelay');
            initAddType=hdlcoder.tp_ufixpt(ceil(log2(constantValue))+1,0);
            initFlagDelayData=hN.addSignal(initAddType,'initFlagDelayData');
            initFlagenable=hN.addSignal(boolType,'initFlagDelayData');
            initFlagAddDataOutDelay=hN.addSignal(initAddType,'initFlagAddDataOutDelay');
            initFlagAddDataOut=hN.addSignal(initAddType,'initFlagAddDataOut');
            latencyValueConstantSignal=hN.addSignal(initAddType,'latencyValueConstantSignal');
            if(zSign||dSign)
                ConstantSignal=hN.addSignal(hdlcoder.tp_sfixpt(QWL,0),'ConstantSignal');
            else
                ConstantSignal=hN.addSignal(hdlcoder.tp_ufixpt(QWL,0),'ConstantSignal');
            end
            isCountReachedFlag=hN.addSignal(boolType,'isCountReachedFlag');
            pirelab.getConstComp(hN,trueFlag,1,'trueFlag');

            pirelab.getConstComp(hN,ConstantSignal,0,'ConstantSignal');
            pirelab.getDTCComp(hN,initFlagenable,initFlagDelayData);
            pirelab.getLogicComp(hN,[initFlagDelay,trueFlag],initFlagenable,'and','andLogic');
            pirelab.getAddComp(hN,[initFlagDelayData,initFlagAddDataOutDelay],initFlagAddDataOut,'Floor','Wrap','Add',hdlcoder.tp_ufixpt(ceil(log2(iterations+1+4)),0),'++');
            pirelab.getUnitDelayComp(hN,initFlagAddDataOut,initFlagAddDataOutDelay,'initFlagAddDataOutDelay',1);
            if(custom&&(divideInfo.customLatency==1||divideInfo.customLatency==2))

                pirelab.getConstComp(hN,latencyValueConstantSignal,constantValue-1,'latencyValue');
            else
                pirelab.getConstComp(hN,latencyValueConstantSignal,constantValue-2,'latencyValue');
            end
            pirelab.getRelOpComp(hN,[initFlagAddDataOut,latencyValueConstantSignal],isCountReachedFlag,'<=',0,sprintf('Relational\nOperator'));
            pirelab.getUnitDelayComp(hN,isCountReachedFlag,initFlagDelay,'initFlagDelay');
        end
    end
    if(zSign||dSign)
        qtempInit=hN.addSignal(hdlcoder.tp_sfixpt(QWL,0),'qtempPost');
        qtempInitOutDTC=hN.addSignal(hdlcoder.tp_sfixpt(QWL,QFL),'qtempPost');
        postCorrectionSig2=hN.addSignal(hdlcoder.tp_sfixpt(QWL,0),'postCorrectionSig2');
        if((zSign==1&&dSign==0)||zSign==0&&dSign==1)
            pirelab.getDTCComp(hN,postCorrectionOutSignal,postCorrectionSig2,'Floor','Saturate','SI','postCorrectionSig2');
        else
            postCorrectionSig2=postCorrectionOutSignal;
        end
        if strcmpi(divideInfo.pipeline,'on')
            if(isLatencyNeeded&&(~(transformnfp.needNoInitialize())))
                pirelab.getSwitchComp(hN,[ConstantSignal,postCorrectionSig2],qtempInit,isCountReachedFlag,'Switch1','~=',0,'Floor','Wrap');
            else
                qtempInit=postCorrectionSig2;
            end
        else
            qtempInit=postCorrectionSig2;
        end
    else
        qtempInit=hN.addSignal(hdlcoder.tp_ufixpt(QWL,0),'qtempPost');
        qtempInitOutDTC=hN.addSignal(hdlcoder.tp_ufixpt(QWL,QFL),'qtempPost');
        if strcmpi(divideInfo.pipeline,'on')
            if(max||(custom&&(divideInfo.customLatency>0))&&((~(transformnfp.needNoInitialize()))))
                pirelab.getSwitchComp(hN,[ConstantSignal,qtempExt_p],qtempInit,isCountReachedFlag,'Switch1','~=',0,'Floor','Wrap');
            else
                qtempInit=qtempExt_p;
            end
        else
            qtempInit=qtempExt_p;
        end
    end
    pirelab.getDTCComp(hN,qtempInit,qtempInitOutDTC,'Floor','Saturate','SI','Data Type Conversion1');
    qoutDTC=hN.addSignal(hOutSignals.Type,'qoutDTC');
    pirelab.getDTCComp(hN,qtempInitOutDTC,qoutDTC,'Floor','Saturate','SI','Data Type Conversion1');

    if strcmpi(divideInfo.pipeline,'on')
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



