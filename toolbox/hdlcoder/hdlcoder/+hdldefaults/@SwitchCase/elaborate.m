function new_hC=elaborate(~,hN,hC)







    hNewNet=pirelab.createNewNetworkWithInterface(...
    'Network',hN,...
    'RefComponent',hC);



    for ii=1:length(hC.PirInputSignals)
        hNewNet.PirInputSignals(ii).SimulinkRate=hC.PirInputSignals(ii).SimulinkRate;
    end

    for ii=1:length(hC.PirOutputSignals)
        hNewNet.PirOutputSignals(ii).SimulinkRate=hC.PirOutputSignals(ii).SimulinkRate;
    end

    hSignalsIn=hNewNet.PirInputSignals;
    hSignalsOut=hNewNet.PirOutputSignals;
    slbh=hC.SimulinkHandle;
    obj=get_param(slbh,'Object');
    portIndices=slResolve(obj.CaseConditions,slbh);

    for ii=1:numel(portIndices)
        cases=portIndices{ii};


        for jj=numel(cases):-1:1


            if numel(cases)>1
                hSignalOut=hNewNet.addSignal(hSignalsOut(ii));
                signals(jj)=hSignalOut;
            else
                hSignalOut=hSignalsOut(ii);
            end

            val=cases(jj);
            pirelab.getCompareToValueComp(...
            hNewNet,hSignalsIn,hSignalOut,'==',val);
        end


        if numel(cases)>1
            pirelab.getLogicComp(hNewNet,signals,hSignalsOut(ii),'or');
        end
    end


    hasDefault=get_param(slbh,'ShowDefaultCase');
    if strcmp(hasDefault,'on')
        signalsIn=hSignalsOut(1:end-1);
        hSignalOut=hNewNet.addSignal(hSignalsOut(end));
        pirelab.getLogicComp(hNewNet,signalsIn,hSignalOut,'or');
        pirelab.getLogicComp(hNewNet,hSignalOut,hSignalsOut(end),'not');
    end

    new_hC=pirelab.instantiateNetwork(hN,hNewNet,hC.PirInputSignals,hC.PirOutputSignals,hC.Name);
end


