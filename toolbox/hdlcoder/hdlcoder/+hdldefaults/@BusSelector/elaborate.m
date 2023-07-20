function newComp=elaborate(~,hN,hC)

    gcb=hC.SimulinkHandle;
    indexArray=get_param(gcb,'OutputSignals');
    outputIsBus=strcmpi(get_param(gcb,'OutputAsBus'),'on');
    newComp=pirelab.getBusSelectorComp(hN,hC.PirInputSignals,hC.PirOutputSignals,...
    indexArray,outputIsBus);
end
