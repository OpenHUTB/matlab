function[sigWidth,sigST,sigComplexity,sigDimensions]=getBlockInfo(~,hC)


    slbh=hC.SimulinkHandle;
    inSig=hC.PirInputSignal(1);
    hT=inSig.Type;

    sigWidth=hT.numElements;


    sigST=get_param(slbh,'CompiledSampleTime');

    sigComplexity=hT.isComplexType||hT.BaseType.isComplexType;

    if~hT.isArrayType
        sigDimensions=1;
    else
        portHandles=get_param(slbh,'PortHandles');
        inportHandle=portHandles.Inport;
        portDimensions=get_param(inportHandle,'CompiledPortDimensions');
        if(length(portDimensions)==2)

            sigDimensions=portDimensions(2);
        else

            parsedPortDimensions=hdlparseportdims(portDimensions,1);
            sigDimensions=parsedPortDimensions(2:end);
        end
    end
end
