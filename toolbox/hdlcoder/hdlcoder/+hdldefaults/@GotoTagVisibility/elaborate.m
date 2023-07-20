function hNewC=elaborate(this,hN,hC)



    slbh=hC.SimulinkHandle;
    tagName=get_param(slbh,'GotoTag');
    hN.updateGotoTagVisibilityData(tagName);
    hNewC=pirelab.getNilComp(hN,hC.PirInputSignals,hC.PirOutputSignals,hC.Name,'',slbh);


end
