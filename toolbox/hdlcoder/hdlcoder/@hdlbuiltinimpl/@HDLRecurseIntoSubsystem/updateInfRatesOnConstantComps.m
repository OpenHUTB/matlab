







function updateInfRatesOnConstantComps(impl,hThisNetwork)

    hOrigThisNetwork=hThisNetwork;
    visitedNW={};
    nwQueue={hThisNetwork};
    while(~isempty(nwQueue))

        hThisNetwork=nwQueue{end};
        nwQueue(end)=[];
        visitedNW{end+1}=hThisNetwork;%#ok<*AGROW>

        vComps=hThisNetwork.Components;
        for jitr=1:length(vComps)
            hC=vComps(jitr);
            if hC.isNetworkInstance()
                if~any(visitedNW==hC.ReferenceNetwork)

                    nwQueue={hC.ReferenceNetwork,nwQueue{:}};%#ok<CCAT>
                end
                continue;
            end

            if~isprop(hC,'BlockTag')||~strcmpi(hC.BlockTag,'built-in/Constant')
                continue;
            end


            if isinf(hC.PirOutputSignal(1).SimulinkRate)||~any(hC.PirOutputSignals(1).SimulinkRate)

                ref_rate=impl.getReferenceRateForConstantBlocks(hOrigThisNetwork,hC);
                hC.PirOutputSignal(1).SimulinkRate=ref_rate;
            end
        end
    end
end
