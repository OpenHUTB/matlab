function actionSignal=actionSignalPred(signal)





    actionSignal=hdlhandles(0,0);
    sigReceivers=signal.getReceivers;
    if~any(arrayfun(@(x)isa(x.Owner,'hdlcoder.network'),sigReceivers))


        return;
    end

    ntwk=signal.Owner;
    inSignals=ntwk.PirInputSignals;
    for ii=1:numel(inSignals)
        networkInSig=inSignals(ii);
        slHandle=networkInSig.SimulinkHandle;
        if slHandle<0
            continue;
        end
        portType=get_param(slHandle,'PortType');
        if strcmp(portType,'ifaction')


            actionSignal=networkInSig;
            return;
        end
    end
end


