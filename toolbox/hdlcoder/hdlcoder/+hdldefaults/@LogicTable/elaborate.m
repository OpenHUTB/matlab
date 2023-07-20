function hNewC=elaborate(this,hN,hC)





    hCInSignals=hC.SLInputSignals;
    hCOutSignals=hC.SLOutputSignals;


    slbh=hC.SimulinkHandle;


    [inputTable,outputTable]=getBlockInfo(this,slbh);


    [minimizedInputTable,minimizedOutputTable]=minimizeLogic(this,inputTable,outputTable);


    hCNotInSignals=hN.addSignal(hCInSignals);
    logicComp=pirelab.getLogicComp(hN,hCInSignals,hCNotInSignals,'not','notInputs');%#ok<NASGU>


    demuxInSignals=pirelab.getDemuxCompOnInput(hN,hCInSignals);
    inSignals=demuxInSignals.PirOutputSignals;


    demuxNotInSignals=pirelab.getDemuxCompOnInput(hN,hCNotInSignals);
    notInSignals=demuxNotInSignals.PirOutputSignals;


    productSignals=hdlhandles(size(minimizedInputTable,1),1);
    for ii=1:size(minimizedInputTable,1)

        trueSignals=inSignals(minimizedInputTable(ii,:));

        complementedSignals=notInSignals(~minimizedInputTable(ii,:));

        productSignals(ii)=hN.addSignal(hdlcoder.tp_boolean,strcat('prod',num2str(ii)));

        logicComp=pirelab.getLogicComp(hN,[trueSignals;complementedSignals],productSignals(ii),'and',strcat('and',num2str(ii)));%#ok<NASGU>
    end


    for ii=1:size(minimizedInputTable,2)

        if(sum(minimizedInputTable(sum(minimizedOutputTable,2)>0,ii))==0)

            inSignal=demuxInSignals.PirOutputSignals(ii);
            nilComp=pirelab.getNilComp(hN,inSignal,[],'terminator',strcat('term',num2str(ii)));
        elseif(sum(minimizedInputTable(sum(minimizedOutputTable,2)>0,ii))==sum(sum(minimizedOutputTable,2)>0))

            notInSignal=demuxNotInSignals.PirOutputSignals(ii);
            nilComp=pirelab.getNilComp(hN,notInSignal,[],'terminator',strcat('term',num2str(ii)));
        end
    end


    sumSignals=hdlhandles(size(minimizedOutputTable,2),1);
    constComp=[];
    for ii=1:size(minimizedOutputTable,2)

        outputSignals=productSignals(minimizedOutputTable(:,ii));

        sumSignals(ii)=hN.addSignal(hdlcoder.tp_boolean,strcat('sum',num2str(ii)));


        if(isempty(outputSignals)&&isempty(constComp))
            constComp=pirelab.getConstComp(hN,sumSignals(ii),0,'zeroConstant');
            continue;
        elseif(isempty(outputSignals)&&~isempty(constComp))

            wireComp=pirelab.getWireComp(hN,constComp.PirOutputSignals,sumSignals(ii));
            continue;
        end
        logicComp=pirelab.getLogicComp(hN,outputSignals,sumSignals(ii),'or',strcat('or',num2str(ii)));%#ok<NASGU>
    end

    hNewC=pirelab.getMuxComp(hN,sumSignals,hCOutSignals,'outputMux');

end
