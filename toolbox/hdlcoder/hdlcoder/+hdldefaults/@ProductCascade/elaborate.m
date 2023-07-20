function hNewC=elaborate(this,hN,hC)



    hCInSignal=hC.PirInputSignals;
    hCOutSignal=hC.PirOutputSignals;


    if(numel(hCInSignal)==1&&prod(hCInSignal.Type.getDimensions)==prod(hCOutSignal.Type.getDimensions))
        slbh=hC.SimulinkHandle;
        rndMode=get_param(slbh,'RndMeth');
        if strcmpi(get_param(slbh,'DoSatur'),'on')
            satMode='Saturate';
        else
            satMode='Wrap';
        end


        if hCInSignal.Type.isDoubleType||hCInSignal.Type.isSingleType

            hNewC=pirelab.getWireComp(hN,hCInSignal,hCOutSignal);
        else

            hNewC=pirelab.getDTCComp(hN,hCInSignal,hCOutSignal,rndMode,satMode);
        end
    else

        hNewNet=pirelab.createNewNetworkWithInterface(...
        'Network',hN,...
        'RefComponent',hC);

        this.elaborateCascadeProduct(hNewNet,hC);

        hNewC=pirelab.instantiateNetwork(hN,hNewNet,hCInSignal,hCOutSignal,hC.Name);

    end

