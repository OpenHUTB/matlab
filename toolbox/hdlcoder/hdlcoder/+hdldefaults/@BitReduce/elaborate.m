function hNewC=elaborate(this,hN,hC)




    slbh=hC.SimulinkHandle;
    reduceMode=get_param(slbh,'mode');

    hNewC=pirelab.getBitReduceComp(hN,hC.SLInputSignals,hC.SLOutputSignals,reduceMode,hC.Name);

end



