
function relayComp=elaborate(this,hN,hC)

    slbh=hC.SimulinkHandle;

    offSwVal=this.getBlockDialogValue(slbh,'OffSwitchValue');
    onSwVal=this.getBlockDialogValue(slbh,'OnSwitchValue');
    onOpVal=this.getBlockDialogValue(slbh,'OnOutputValue');
    offOpVal=this.getBlockDialogValue(slbh,'OffOutputValue');

    hOutSignals=hC.PirOutputSignals;
    hInSignals=hC.PirInputSignals;
    compName=hdllegalname(hC.Name);
    relayComp=pirelab.getRelayComp(hN,hC,hInSignals,hOutSignals,compName,onSwVal,offSwVal,onOpVal,offOpVal);

    return
end






