function hNewC=elaborate(this,hN,hC)







    if strcmp(hdlfeature('GenEMLHDLCounter'),'on')

        cntComp=pirelab.getCounterFreeRunningComp(hN,hC.SLOutputSignals,hC.Name);

        hNewC=cntComp;
    else
        pirTyp1=hC.PirOutputSignals.Type;
        slRate=hC.PirOutputSignals.SimulinkRate;
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
        countNext_s=addSignal(counterNet,'count',pirTyp1,slRate);
        countStep_s=addSignal(counterNet,'count_step',pirTyp1,slRate);

        pirelab.getIntDelayComp(counterNet,...
        countNext_s,...
        count_s,...
        1,hC.Name,...
        fi(0,false,numBits,0),...
        0,0,[],0,0);


        pirelab.getAddComp(counterNet,...
        [count_s,countStep_s],...
        countNext_s,...
        'Floor','Wrap','adder',pirTyp1,'++');

        pirelab.getConstComp(counterNet,...
        countStep_s,...
        fi(1,false,numBits,0),...
        'step_value','off',0,'','','');

        cntComp=pirelab.instantiateNetwork(hN,counterNet,hC.PirInputSignals,hC.PirOutputSignals,hC.Name);

        cntComp.OrigModelHandle=hC.OrigModelHandle;


        traceComment=hC.getComment;
        cntComp.addTraceabilityComment(traceComment);


        comment=blockComment();
        cntComp.addComment(comment);

        hNewC=cntComp;
    end
end


function str=blockComment()

    nl=newline;

    comment=['Free running',', ','Unsigned',' Counter',nl...
    ,' initial value   = 0',nl...
    ,' step value      = 1'];

    str=[hdlformatcomment(comment,2),nl];
end


function signal=addSignal(network,name,pirType,slRate)
    signal=network.addSignal2('Name',name,'Type',pirType);
    signal.SimulinkRate=slRate;
end
