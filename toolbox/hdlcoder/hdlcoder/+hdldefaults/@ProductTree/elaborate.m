function treeComp=elaborate(this,hN,hC)



    slbh=hC.SimulinkHandle;

    [rndMode,satMode,dspMode,nfpOptions]=this.getBlockInfo(hC,slbh);


    hCInSignals=hC.PirInputSignals;
    hCOutSignals=hC.PirOutputSignals;
    hCInPorts=hC.PirInputPorts;
    hCOutPorts=hC.PirOutputPorts;


    opName='product';
    mulKind=get_param(hC.SimulinkHandle,'Multiplication');
    isPOE=((numel(hCInSignals)==1)&&strcmp(mulKind,'Element-wise(.*)'));
    need2ReDrawModelfromPir=false;
    nDims=1;
    if isPOE

        if hCInSignals(1).Type.isMatrix
            [hCInSignals,hCInPorts,hCOutSignals,hCOutPorts,nDims]=splitMatrix2SpecifiedDims(hN,hCInSignals,hCOutSignals,hCInPorts,hCOutPorts);
            need2ReDrawModelfromPir=true;
        end

        if prod(hCInSignals(1).Type.getDimensions)==prod(hCOutSignals(1).Type.getDimensions)
            need2ReDrawModelfromPir=true;
        end
    end


    for ii=1:nDims
        if needTreeArch(this,hC,hCInSignals(ii),hCOutSignals(ii))

            treeComp=getTreeArchitecture(this,hN,hN,hCInSignals(ii),hCInPorts(ii),hCOutPorts(ii),opName,rndMode,satMode,hC.Name,false,[],dspMode,nfpOptions);

        else

            treeComp=pirelab.getDTCComp(hN,hCInSignals(ii),hCOutSignals(ii),rndMode,satMode);
        end
    end

    if need2ReDrawModelfromPir


        hN.generateModelFromPir;
    end
end


