function recipComp=getReciprocalComp(hN,hInSignals,hOutSignals,newtonInfo)


    narginchk(4,4);
    if newtonInfo.iterNum>0


        if~newtonInfo.isRsqrtBased

            if newtonInfo.isMultirate
                hNewtonNet=pirelab.getRecipNewtonNetwork(hN,hInSignals,hOutSignals,newtonInfo);

            else
                hNewtonNet=pirelab.getRecipNewtonSingleRateNetwork(hN,hInSignals,hOutSignals,newtonInfo);
            end

        else

            if newtonInfo.isMultirate
                hNewtonNet=pirelab.getRecipNewtonRsqrtBasedNetwork(hN,hInSignals,hOutSignals,newtonInfo);

            else
                hNewtonNet=pirelab.getRecipNewtonRsqrtBasedSingleRateNetwork(hN,hInSignals,hOutSignals,newtonInfo);
            end
        end



        recipComp=pirelab.instantiateNetwork(hN,hNewtonNet,hInSignals,hOutSignals,...
        newtonInfo.networkName);

    else
        recipComp=pirelab.getReciprocalDivComp(hN,hInSignals,hOutSignals,...
        newtonInfo.rndMode,newtonInfo.satMode,newtonInfo.networkName);
    end
end
