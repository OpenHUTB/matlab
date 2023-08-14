function sqrtComp=getSqrtNewtonComp(hN,hInSignals,hOutSignals,newtonInfo)


    narginchk(4,4);

    hNewtonNet=pirelab.getSqrtNewtonNetwork(hN,hInSignals,hOutSignals,newtonInfo);

    sqrtComp=pirelab.instantiateNetwork(hN,hNewtonNet,hInSignals,hOutSignals,...
    newtonInfo.networkName);
end
