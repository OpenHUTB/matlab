function hNewC=elaborate(this,hN,hC)


    [sigWidth,sigST,sigComplexity,sigDimensions]=this.getBlockInfo(hC);

    slbh=hC.SimulinkHandle;
    inSig=hC.PirInputSignal(1);

    index=1;




    if(strcmp(get_param(slbh,'ProbeWidth'),'on'))
        hNewC=pirelab.getConstComp(hN,hC.PIROutputSignals(index),...
        sigWidth,[hC.Name,'_width']);
        index=index+1;
    end
    if(strcmp(get_param(slbh,'ProbeSampleTime'),'on'))
        hNewC=pirelab.getConstComp(hN,hC.PIROutputSignals(index),...
        sigST,[hC.Name,'_sampleTime']);
        index=index+1;
    end
    if(strcmp(get_param(slbh,'ProbeComplexSignal'),'on'))
        hNewC=pirelab.getConstComp(hN,hC.PIROutputSignals(index),...
        sigComplexity,[hC.Name,'_complex']);
        index=index+1;
    end
    if(strcmp(get_param(slbh,'ProbeSignalDimensions'),'on'))
        hNewC=pirelab.getConstComp(hN,hC.PIROutputSignals(index),...
        sigDimensions,[hC.Name,'_dimensions']);
    end


    pirelab.getNilComp(hN,inSig);
end

