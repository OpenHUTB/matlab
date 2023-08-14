function hNewC=elaborate(this,hN,hC)





    slbh=hC.SimulinkHandle;


    count_limit=this.hdlslResolve('uplimit',slbh);


    outputRate=hC.SLOutputSignals.SimulinkRate;

    if strcmp(hdlfeature('GenEMLHDLCounter'),'on')

        cntComp=pirelab.getCounterLimitedComp(hN,hC.SLOutputSignals,count_limit,outputRate,hC.Name);

        hNewC=cntComp;
    else
        pirTyp1=hC.PirOutputSignals.Type;
        numBits=pirTyp1.WordLength;
        outPortName{1}=hC.PirOutputSignals(1).Name;


        counterNet=pirelab.createNewNetworkWithInterface(...
        'Network',hN,...
        'RefComponent',hC,...
        'InportNames','',...
        'OutportNames',outPortName...
        );


        counterNet.setFlattenHierarchy('on');

        count_s=counterNet.PirOutputSignals(1);
        countFinal_s=addSignal(counterNet,'count_value',pirTyp1,outputRate);
        countNext_s=addSignal(counterNet,'count',pirTyp1,outputRate);
        countStep_s=addSignal(counterNet,'count_step',pirTyp1,outputRate);
        countFrom_s=addSignal(counterNet,'count_from',pirTyp1,outputRate);
        needToWrap_s=addSignal(counterNet,'needToWrap',pir_boolean_t,outputRate);

        pirelab.getIntDelayComp(counterNet,...
        countFinal_s,...
        count_s,...
        1,hC.Name,...
        fi(0,false,numBits,0),...
        0,0,[],0,0);

        pirelab.getSwitchComp(counterNet,...
        [countFrom_s,countNext_s],...
        countFinal_s,...
        needToWrap_s,'switch',...
        '~=',0,'Floor','Wrap');

        pirelab.getCompareToValueComp(counterNet,...
        count_s,...
        needToWrap_s,...
        '>=',fi(count_limit,0,numBits,0),...
        'compare',0);

        pirelab.getConstComp(counterNet,...
        countFrom_s,...
        fi(0,false,numBits,0),...
        'count_from','off',0,'','','');

        pirelab.getAddComp(counterNet,...
        [count_s,countStep_s],...
        countNext_s,...
        'Floor','Wrap','adder',pirTyp1,'++');

        pirelab.getConstComp(counterNet,...
        countStep_s,...
        fi(1,false,numBits,0),...
        'step_value','off',0,'','','');

        cntComp=pirelab.instantiateNetwork(hN,counterNet,hC.PirInputSignals,hC.PirOutputSignals,hC.Name);


        traceComment=hC.getComment;
        cntComp.addTraceabilityComment(traceComment);


        comment=blockComment(count_limit);
        cntComp.addComment(comment);

        hNewC=cntComp;

    end
end

function str=blockComment(countLimit)

    nl=newline;

    comment=['Count limited',', ','Unsigned',' Counter',nl...
    ,' initial value   = 0',nl...
    ,' step value      = 1',nl...
    ,' count to value  = ',num2str(countLimit)];

    str=[hdlformatcomment(comment,2),nl];
end

function signal=addSignal(network,name,pirType,slRate)
    signal=network.addSignal2('Name',name,'Type',pirType);
    signal.SimulinkRate=slRate;
end
