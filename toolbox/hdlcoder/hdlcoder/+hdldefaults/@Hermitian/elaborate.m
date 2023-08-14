function hNewC=elaborate(this,hN,hC)



    slbh=hC.SimulinkHandle;


    satMode=strcmpi(get_param(slbh,'SaturateOnIntegerOverflow'),'on');


    outSigType=get_param(slbh,'OutputSignalType');


    hNewC=pirelab.getHermitianComp(hN,hC.PirInputSignals,hC.PirOutputSignals,satMode,hC.Name,outSigType);

end
