function hNewC=elaborate(this,hN,blockComp)




    hInSignals=blockComp.PirInputSignals;
    hOutSignals=blockComp.PirOutputSignals;
    fname=get_param(blockComp.SimulinkHandle,'Function');
    [~,dataType]=targetmapping.isValidDataType(hInSignals(1).Type);
    if(targetcodegen.targetCodeGenerationUtils.isALTFPMode()&&strcmp(dataType,'single'))...
        ||(targetcodegen.targetCodeGenerationUtils.isALTERAFPFUNCTIONSMode()&&(strcmp(dataType,'single')||strcmp(dataType,'double')))
        hNewC=pirelab.getTrigonometricComp(hN,hInSignals,hOutSignals,...
        blockComp.Name,-1,fname);
    else
        impl=getFunctionImpl(this,blockComp);
        hNewC=impl.elaborate(hN,blockComp);
    end
