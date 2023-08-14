function tbNet=elabTracebackUnit(~,topNet,blockInfo,dataRate)





    t=blockInfo.trellis;
    numStates=t.numStates;



    ufix1Type=pir_ufixpt_t(1,0);
    decvType=pirelab.getPirVectorType(ufix1Type,numStates);

    idxWL=ceil(log2(numStates));
    idxType=pir_ufixpt_t(idxWL,0);



    inportnames={'dec_in','idx_in'};
    inporttypes=[decvType,idxType];
    inportrates=[dataRate,dataRate];

    if blockInfo.hasResetPort
        inportnames{end+1}='tb_reset';
        inporttypes(end+1)=ufix1Type;
        inportrates(end+1)=dataRate;
    end


    tbNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','TracebackUnit',...
    'InportNames',inportnames,...
    'InportTypes',inporttypes,...
    'InportRates',inportrates,...
    'OutportNames',{'dec_out','idx_out'},...
    'OutportTypes',[decvType,idxType]);


    decin=tbNet.PirInputSignals(1);
    idxin=tbNet.PirInputSignals(2);
    decout=tbNet.PirOutputSignals(1);
    idxout=tbNet.PirOutputSignals(2);

    if blockInfo.hasResetPort
        tbreset=tbNet.PirInputSignals(3);
    else
        tbreset=[];
    end



    thread=tbNet.addSignal(ufix1Type,'thread');

    scomp=pirelab.getSwitchComp(tbNet,decin,thread,idxin);
    scomp.addComment('Decode the previous state based on current state and the decision branch');

    sliceType=pir_ufixpt_t(idxWL-1,0);
    slicedidx=tbNet.addSignal(sliceType,'slicedidx');
    pirelab.getBitSliceComp(tbNet,idxin,slicedidx,idxWL-2,0);
    pirelab.getBitConcatComp(tbNet,[slicedidx,thread],idxout);

    if isempty(tbreset)
        pirelab.getUnitDelayComp(tbNet,decin,decout,'decshiftRegister');
    else







        tbresetEnb=tbreset;
        pirelab.getUnitDelayResettableComp(tbNet,decin,decout,tbresetEnb,'decshiftRegister',0,'',true);
    end
