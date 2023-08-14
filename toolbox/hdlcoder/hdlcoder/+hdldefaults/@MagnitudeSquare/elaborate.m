function hNewC=elaborate(this,hN,hC)




    in=hC.PirInputPorts(1).Signal;
    out=hC.PirOutputPorts(1).Signal;
    isInputFloat=targetmapping.isValidDataType(in.Type);
    isOutputFloat=targetmapping.isValidDataType(out.Type);

    slbh=hC.SimulinkHandle;
    outSigType=get_param(slbh,'OutputSignalType');
    if(isInputFloat||isOutputFloat)
        nfpOptions=getNFPBlockInfo(this);
        hNewC=magnitude2FloatImpl(this,hN,hC,hC.PirInputSignals,hC.PirOutputSignals,nfpOptions,outSigType);
    else

        sat=get_param(slbh,'SaturateOnIntegerOverflow');
        if strcmp(sat,'on')
            satMode='Saturate';
        else
            satMode='Wrap';
        end
        rndMode=get_param(slbh,'RndMeth');

        hNewC=pirelab.getMagnitudeSquareComp(hN,hC.PirInputSignals,hC.PirOutputSignals,satMode,rndMode,hC.Name,outSigType);
    end
