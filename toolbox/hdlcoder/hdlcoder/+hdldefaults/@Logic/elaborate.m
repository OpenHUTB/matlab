function hNewC=elaborate(this,hN,hC)%#ok<INUSL>


    slbh=hC.SimulinkHandle;
    op=lower(get_param(slbh,'Operator'));
    compName=hC.Name;

    hNewC=pirelab.getLogicComp(hN,hC.SLInputSignals,hC.SLOutputSignals,op,compName,'');%#ok<NASGU>
