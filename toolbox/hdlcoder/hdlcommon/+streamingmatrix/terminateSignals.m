




function terminateSignals(p)

    for ntwkIdx=1:numel(p.Networks)
        hN=p.Networks(ntwkIdx);

        for sigIdx=1:numel(hN.Signals)
            sig=hN.Signals(sigIdx);
            if isempty(sig.getReceivers)&&...
                ~strcmp(sig.getDrivers.Kind,'subsystem_enable')
                hC=pirelab.getNilComp(hN,sig,[],'Terminator');
            end
        end
    end

end


