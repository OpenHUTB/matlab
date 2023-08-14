function hNewC=elaborate(this,hN,hC)







    slbh=hC.SimulinkHandle;
    rotateMode=get_param(slbh,'mode');
    rotateLength=hdlslResolve('N',slbh);

    hNewC=pirelab.getBitRotateComp(hN,hC.SLInputSignals,hC.SLOutputSignals,rotateMode,rotateLength,hC.Name);

end
