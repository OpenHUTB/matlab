function hNewC=elaborate(this,hN,hC)


    hCInSignals=hC.SLInputSignals;
    hCOutSignals=hC.SLOutputSignals;
    slbh=hC.SimulinkHandle;

    ovMode='Saturate';
    rndMode='Nearest';
    pipelineDepth=0;


    adderSign='++';


    nfpOptions=getNFPBlockInfo(this);

    fusedStr=get_param(slbh,'FMA');

    if strcmp(fusedStr,'on')
        fused=true;
    else
        fused=false;
    end


    hNewC=pirelab.getScalarMACComp(hN,hCInSignals,hCOutSignals,rndMode,ovMode,hC.Name,'',slbh,pipelineDepth,adderSign,...
    nfpOptions,fused);
end


