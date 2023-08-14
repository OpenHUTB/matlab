function hNewC=elaborate(~,hN,hC)


    maskvar=get_param(hC.SimulinkHandle,'MaskWSVariables');
    op=maskvar(arrayfun(@(x)strcmp(x.Name,'relop'),maskvar)).Value;
    hNewC=pirelab.getCompareToValueComp(hN,hC.SLInputSignals,hC.SLOutputSignals,op,0,hC.Name);
end
