function recipComp=getRecipSqrtNewtonComp(hN,hInSignals,hOutSignals,newtonInfo)


    narginchk(4,4);

    hNewtonNet=pirelab.getRecipSqrtNewtonNetwork(hN,hInSignals,hOutSignals,newtonInfo);

    recipComp=pirelab.instantiateNetwork(hN,hNewtonNet,hInSignals,hOutSignals,...
    newtonInfo.networkName);
end
