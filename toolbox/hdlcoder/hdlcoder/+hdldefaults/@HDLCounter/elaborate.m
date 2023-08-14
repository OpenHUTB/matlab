function cntComp=elaborate(this,hN,hC)






    CInfo=this.getBlockInfo(hC);


    if strcmp(hdlfeature('GenEMLHDLCounter'),'on')

        cntComp=pirelab.getCounterComp(hN,hC.PirInputSignals,hC.PirOutputSignals,...
        CInfo.Countertype,CInfo.InitValues,CInfo.StepValue,CInfo.CountToValue,...
        CInfo.Localresetport,CInfo.Loadport,CInfo.Countenableport,...
        CInfo.CountdirectionPort,hC.Name,CInfo.CountFromValue);
    else

        pirTyp1=hC.PirOutputSignals(1).Type;
        isSigned=pirTyp1.Signed;

        countWordLen=pirTyp1.WordLength;
        countFracLen=-pirTyp1.FractionLength;
        countStepData=CInfo.StepValue;
        countFrom=CInfo.CountFromValue;
        countMax=CInfo.CountToValue;
        countInit=CInfo.InitValues;
        countType=CInfo.Countertype;
        hasReset=CInfo.Localresetport;
        hasEnable=CInfo.Countenableport;
        hasLoad=CInfo.Loadport;
        hasDir=CInfo.CountdirectionPort;
        hasCountHitOutPort=CInfo.CounthitPort;


        isFreeRunning=strcmp(countType,'Free running');
        isModulo=strcmp(countType,'Modulo');

        if isModulo
            maxval_sc=max(countMax,countFrom);
            minval_sc=min(countMax,countFrom);
        elseif isFreeRunning
            maxval_sc=(2^pirTyp1.WordLength-1)*(2^countFracLen);
            minval_sc=countFrom;
        else
            maxval_sc=countMax;
            minval_sc=countFrom;
        end


        if countStepData>0
            countStep=countStepData;
        else
            countStep=-countStepData;
        end



        counterNet=createNetworkForCounter(hN,hC);



        counterNet.setFlattenHierarchy('on');


        [reset_in,load_in,loadVal_in,enable_in,dir_in]=getCountInPorts(counterNet,hasReset,hasLoad,hasEnable,hasDir);


        slRate=hC.PirOutputSignals(1).SimulinkRate;


        count_s=counterNet.PirOutputSignals(1);
        count_hit_s='';
        if hasCountHitOutPort
            count_hit_s=counterNet.PirOutputSignals(2);
            count_hit_s.SimulinkRate=slRate;
        end


        count_s7=addSignal(counterNet,'count_value',pirTyp1,slRate);
        countNext_s=addSignal(counterNet,'count',pirTyp1,slRate);
        countNext_add=addSignal(counterNet,'count',pirTyp1,slRate);
        countNext_sub=addSignal(counterNet,'count',pirTyp1,slRate);
        count_reset=addSignal(counterNet,'count_reset',pirTyp1,slRate);
        countStep_s=addSignal(counterNet,'count_step',pirTyp1,slRate);

        count_hit_1=addSignal(counterNet,'count_hit',pir_boolean_t,slRate);


        pirelab.getConstComp(counterNet,...
        countStep_s,...
        fi(countStep,isSigned,countWordLen,countFracLen),...
        'step_value','off',0,'','','');
        if hasLoad||hasReset
            count_hit_temp=count_hit_1;
        else
            count_hit_temp=count_hit_s;
        end

        if~hasDir
            if countStepData>0
                [countNext_s,count_hit_temp]=createUpCounter(counterNet,count_s,countStep_s,countNext_s,...
                pirTyp1,isModulo,isFreeRunning,countFrom,maxval_sc,minval_sc,countStepData,count_hit_temp,hasCountHitOutPort,slRate);
            else
                [countNext_s,count_hit_temp]=createDownCounter(counterNet,count_s,countStep_s,countNext_s,...
                pirTyp1,isModulo,isFreeRunning,countFrom,maxval_sc,minval_sc,countStepData,count_hit_temp,hasCountHitOutPort,slRate);

            end
            count_output=countNext_s;
        else
            if countStepData>0
                [countNext_add,~]=createUpCounter(counterNet,count_s,countStep_s,countNext_add,...
                pirTyp1,isModulo,isFreeRunning,countFrom,maxval_sc,minval_sc,countStepData,count_hit_1,hasCountHitOutPort,slRate);
                [countNext_sub,~]=createDownCounter(counterNet,count_s,countStep_s,countNext_sub,...
                pirTyp1,isModulo,isFreeRunning,countFrom,maxval_sc,minval_sc,-countStepData,count_hit_1,hasCountHitOutPort,slRate);

            else
                [countNext_add,~]=createDownCounter(counterNet,count_s,countStep_s,countNext_add,...
                pirTyp1,isModulo,isFreeRunning,countFrom,maxval_sc,minval_sc,countStepData,count_hit_1,hasCountHitOutPort,slRate);
                [countNext_sub,~]=createUpCounter(counterNet,count_s,countStep_s,countNext_sub,...
                pirTyp1,isModulo,isFreeRunning,countFrom,maxval_sc,minval_sc,-countStepData,count_hit_1,hasCountHitOutPort,slRate);

            end

            pirelab.getSwitchComp(counterNet,...
            [countNext_add,countNext_sub],...
            count_s7,...
            dir_in,'switchDirection',...
            '~=',0,'Floor','Wrap');
            count_output=count_s7;
        end

        count_final_after_enable=addSignal(counterNet,'count',pirTyp1,slRate);
        if hasEnable
            pirelab.getSwitchComp(counterNet,...
            [count_s,count_output],...
            count_final_after_enable,...
            enable_in,'switchEnable',...
            '==',0,'Floor','Wrap');
            count_output=count_final_after_enable;
        end

        count_final_after_load=addSignal(counterNet,'count',pirTyp1,slRate);
        if hasLoad
            pirelab.getSwitchComp(counterNet,...
            [loadVal_in,count_output],...
            count_final_after_load,...
            load_in,'switchLoad',...
            '~=',0,'Floor','Wrap');
            count_output=count_final_after_load;
        end

        count_final_after_reset=addSignal(counterNet,'count',pirTyp1,slRate);
        if hasReset
            pirelab.getConstComp(counterNet,...
            count_reset,...
            fi(countInit,isSigned,countWordLen,countFracLen),...
            'const','off',0,'','','');
            pirelab.getSwitchComp(counterNet,...
            [count_reset,count_output],...
            count_final_after_reset,...
            reset_in,'switchReset',...
            '~=',0,'Floor','Wrap');
            count_output=count_final_after_reset;
        end

        is_count_set_explicitly=addSignal(counterNet,'is_count_set_explicitly',pir_boolean_t,slRate);

        if hasCountHitOutPort
            if hasLoad||hasReset
                if hasLoad&&hasReset
                    pirelab.getLogicComp(counterNet,...
                    [load_in,reset_in],...
                    is_count_set_explicitly,'or');
                    count_set_explicitly=is_count_set_explicitly;

                elseif hasLoad
                    count_set_explicitly=load_in;
                elseif hasReset
                    count_set_explicitly=reset_in;
                end
                zero_s=addSignal(counterNet,'zero',pir_boolean_t,slRate);


                pirelab.getConstComp(counterNet,...
                zero_s,...
                fi(0,0,1,0),...
                'zero','off',0,'','','');

                pirelab.getSwitchComp(counterNet,...
                [zero_s,count_hit_temp],...
                count_hit_s,...
                count_set_explicitly,'switchReset',...
                '~=',0,'Floor','Wrap');
            end

        end

        pirelab.getIntDelayComp(counterNet,...
        count_output,...
        count_s,...
        1,hC.Name,...
        fi(countInit,isSigned,countWordLen,countFracLen),...
        0,0,[],0,0);



        cntComp=pirelab.instantiateNetwork(hN,counterNet,hC.PirInputSignals,hC.PirOutputSignals,hC.Name);

        cntComp.OrigModelHandle=hC.OrigModelHandle;


        comment=blockComment(isFreeRunning,isModulo,isSigned,countStepData,countMax,countFrom);
        cntComp.addComment(comment);


        traceComment=hC.getComment;
        cntComp.addTraceabilityComment(traceComment);
    end

end

function[countOut,count_hit_s]=createUpCounter(counterNet,count_s,countStep_s,countNext_s,...
    pirTyp1,isModulo,isFreeRunning,countFrom,countMax,countMin,countStepData,count_hit_s,hasCountHitOutPort,slRate)

    countWordLen=pirTyp1.WordLength;
    isSigned=pirTyp1.Signed;
    countFracLen=-pirTyp1.FractionLength;

    pirelab.getAddComp(counterNet,...
    [count_s,countStep_s],...
    countNext_s,...
    'Floor','Wrap','adder',pirTyp1,'++');

    if isFreeRunning
        countOut=countNext_s;
    else
        countFrom_s=addSignal(counterNet,'count_from',pirTyp1,slRate);
        if isModulo
            modValue_s14=addSignal(counterNet,'modValue',pirTyp1,slRate);
            pirelab.getConstComp(counterNet,...
            modValue_s14,...
            fi((countMax+1-countMin-countStepData),isSigned,countWordLen,countFracLen),...
            'const','off',0,'','','');
            pirelab.getAddComp(counterNet,...
            [count_s,modValue_s14],...
            countFrom_s,...
            'Floor','Wrap','moduloWrap',pirTyp1,'+-');
            counterWrapCond=countMax-countStepData;
            counterLimitCheckOp='>';
        else
            pirelab.getConstComp(counterNet,...
            countFrom_s,...
            fi(countFrom,isSigned,countWordLen,countFracLen),...
            'countFrom','off',0,'','','');
            counterWrapCond=countMax;
            counterLimitCheckOp='==';
        end
        count_s7=addSignal(counterNet,'count_value',pirTyp1,slRate);
        out0_s9=addSignal(counterNet,'need_to_wrap',pir_boolean_t,slRate);

        pirelab.getSwitchComp(counterNet,...
        [countFrom_s,countNext_s],...
        count_s7,...
        out0_s9,'switch',...
        '~=',0,'Floor','Wrap');
        pirelab.getCompareToValueComp(counterNet,...
        count_s,...
        out0_s9,...
        counterLimitCheckOp,fi(counterWrapCond,isSigned,countWordLen,countFracLen),...
        'compare',0);
        countOut=count_s7;
    end
    if hasCountHitOutPort
        if isModulo
            pirelab.getWireComp(counterNet,out0_s9,count_hit_s);
        else
            rangeUpperBound=pirelab.getTypeInfoAsFi(pirTyp1,'Floor','Wrap',...
            upperbound(fi(0,isSigned,countWordLen,countFracLen)));
            rangeCounterWrapCond=fi(rangeUpperBound-countStepData,isSigned,countWordLen,countFracLen);

            rangeCounterLimitCheckOp='>';
            if isFreeRunning
                pirelab.getCompareToValueComp(counterNet,...
                count_s,...
                count_hit_s,...
                rangeCounterLimitCheckOp,rangeCounterWrapCond,...
                'compare',0);
            else
                range_hit_s=addSignal(counterNet,'range_hit',pir_boolean_t,slRate);

                pirelab.getCompareToValueComp(counterNet,...
                count_s,...
                range_hit_s,...
                rangeCounterLimitCheckOp,rangeCounterWrapCond,...
                'compare',0);
                pirelab.getLogicComp(counterNet,...
                [out0_s9,range_hit_s],...
                count_hit_s,'or');
            end

        end
    end
end



function[countOut,count_hit_s]=createDownCounter(counterNet,count_s,countStep_s,countNext_s,...
    pirTyp1,isModulo,isFreeRunning,countFrom,countMax,countMin,countStepData,count_hit_s,hasCountHitOutPort,slRate)

    countWordLen=pirTyp1.WordLength;
    countFracLen=-pirTyp1.FractionLength;
    isSigned=pirTyp1.Signed;

    pirelab.getAddComp(counterNet,...
    [count_s,countStep_s],...
    countNext_s,...
    'Floor','Wrap','adder',pirTyp1,'+-');
    if isFreeRunning
        countOut=countNext_s;
    else
        countFrom_s=addSignal(counterNet,'count_from',pirTyp1,slRate);
        if isModulo
            modValue_s14=addSignal(counterNet,'modValue',pirTyp1,slRate);
            pirelab.getConstComp(counterNet,...
            modValue_s14,...
            fi((countMax+1-countMin+countStepData),isSigned,countWordLen,countFracLen),...
            'const','off',0,'','','');
            pirelab.getAddComp(counterNet,...
            [count_s,modValue_s14],...
            countFrom_s,...
            'Floor','Wrap','moduloWrap',pirTyp1,'++');
            counterWrapCond=countMin-countStepData;
            counterLimitCheckOp='<';
        else
            pirelab.getConstComp(counterNet,...
            countFrom_s,...
            fi(countFrom,isSigned,countWordLen,countFracLen),...
            'countFrom','off',0,'','','');
            counterWrapCond=countMax;
            counterLimitCheckOp='==';
        end
        count_s7=addSignal(counterNet,'count_value',pirTyp1,slRate);
        out0_s9=addSignal(counterNet,'need_to_wrap',pir_boolean_t,slRate);

        pirelab.getSwitchComp(counterNet,...
        [countFrom_s,countNext_s],...
        count_s7,...
        out0_s9,'switch',...
        '~=',0,'Floor','Wrap');

        pirelab.getCompareToValueComp(counterNet,...
        count_s,...
        out0_s9,...
        counterLimitCheckOp,fi(counterWrapCond,isSigned,countWordLen,countFracLen),...
        'compare',0);
        countOut=count_s7;
    end

    if hasCountHitOutPort
        if isModulo
            pirelab.getWireComp(counterNet,out0_s9,count_hit_s);
        else
            rangeLowerBound=pirelab.getTypeInfoAsFi(pirTyp1,'Floor','Wrap',...
            lowerbound(fi(0,isSigned,countWordLen,countFracLen)));
            rangeCounterWrapCond=fi(rangeLowerBound-countStepData,isSigned,countWordLen,countFracLen);
            rangeCounterLimitCheckOp='<';
            if isFreeRunning
                pirelab.getCompareToValueComp(counterNet,...
                count_s,...
                count_hit_s,...
                rangeCounterLimitCheckOp,rangeCounterWrapCond,...
                'compare',0);
            else
                range_hit_s=addSignal(counterNet,'range_hit',pir_boolean_t,slRate);

                pirelab.getCompareToValueComp(counterNet,...
                count_s,...
                range_hit_s,...
                rangeCounterLimitCheckOp,rangeCounterWrapCond,...
                'compare',0);
                pirelab.getLogicComp(counterNet,...
                [out0_s9,range_hit_s],...
                count_hit_s,'or');
            end
        end
    end
end


function counterNet=createNetworkForCounter(hN,hC)

    hInSignals=hC.PirInputSignals;
    numInSignals=length(hInSignals);
    hOutSignals=hC.PirOutputSignals;
    numOutSignals=length(hOutSignals);


    inportNames=strings(numInSignals,1);
    outportNames=strings(numOutSignals,1);


    for i=1:numInSignals
        inportNames{i}=hInSignals(i).Name;
    end


    for i=1:length(hOutSignals)
        outportNames{i}=hOutSignals(i).Name;
    end


    counterNet=pirelab.createNewNetworkWithInterface(...
    'Network',hN,...
    'RefComponent',hC,...
    'InportNames',inportNames,...
    'OutportNames',outportNames...
    );
end

function[reset_in,load_in,loadVal_in,enable_in,dir_in]=getCountInPorts(counterNet,hasReset,hasLoad,hasEnable,hasDir)
    inputSignalIndex=1;

    reset_in='';
    if hasReset
        reset_in=counterNet.PirInputSignals(inputSignalIndex);
        inputSignalIndex=inputSignalIndex+1;
    end

    load_in='';
    loadVal_in='';
    if hasLoad
        load_in=counterNet.PirInputSignals(inputSignalIndex);
        inputSignalIndex=inputSignalIndex+1;
        loadVal_in=counterNet.PirInputSignals(inputSignalIndex);
        inputSignalIndex=inputSignalIndex+1;
    end

    enable_in='';
    if hasEnable
        enable_in=counterNet.PirInputSignals(inputSignalIndex);
        inputSignalIndex=inputSignalIndex+1;
    end

    dir_in='';
    if hasDir
        dir_in=counterNet.PirInputSignals(inputSignalIndex);
    end

end

function str=blockComment(isFreeRunning,isModulo,isSignedType,countStepData,countMax,countFrom)


    nl=newline;

    if isFreeRunning
        Countertype='Free running';
        count_to_value='';

    elseif isModulo
        Countertype='Modulo';
        count_to_value=[...
        nl,' count to value  = ',num2str(countMax)];
    else
        Countertype='Count limited';
        count_to_value=[...
        nl,' count to value  = ',num2str(countMax)];
    end

    if isSignedType
        Outputdatatype='Signed';
    else
        Outputdatatype='Unsigned';
    end

    comment=[Countertype,', ',Outputdatatype,' Counter',nl...
    ,' initial value   = ',num2str(countFrom),nl...
    ,' step value      = ',num2str(countStepData)...
    ,count_to_value];

    str=[hdlformatcomment(comment,2),nl];

end

function signal=addSignal(network,name,pirType,slRate)
    signal=network.addSignal2('Name',name,'Type',pirType);
    signal.SimulinkRate=slRate;
end

