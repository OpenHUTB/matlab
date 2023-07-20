function hC=getRisingEdgeDetectionComp(hN,hInSignals,hOutSignals)









    ufix1Type=pir_ufixpt_t(1,0);
    edge_in_reg=hN.addSignal(ufix1Type,'edge_in_reg');
    edge_not=hN.addSignal(ufix1Type,'edge_not');
    edge_and=hN.addSignal(ufix1Type,'edge_and');


    hC=pirelab.getUnitDelayComp(hN,hInSignals,edge_in_reg,'edge_reg',1);


    pirelab.getBitwiseOpComp(hN,edge_in_reg,edge_not,'NOT');
    pirelab.getBitwiseOpComp(hN,[edge_not,hInSignals],edge_and,'AND');


    pirelab.getUnitDelayComp(hN,edge_and,hOutSignals);
