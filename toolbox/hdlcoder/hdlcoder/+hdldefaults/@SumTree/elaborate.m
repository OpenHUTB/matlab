function treeComp=elaborate(this,hN,hC)



    slbh=hC.SimulinkHandle;


    rndMode=get_param(slbh,'RndMeth');
    if strcmpi(get_param(slbh,'DoSatur'),'on')
        satMode='Saturate';
    else
        satMode='Wrap';
    end


    hCInSignals=hC.PirInputSignals;
    hCOutSignals=hC.PirOutputSignals;
    hCInPorts=hC.PirInputPorts;
    hCOutPorts=hC.PirOutputPorts;


    opName='sum';
    nfpOptions=getNFPBlockInfo(this);
    nDims=1;
    need2ReDrawModelfromPir=false;

    if hCInSignals(1).Type.isMatrix&&numel(hCInSignals)==1

        [hCInSignals,hCInPorts,hCOutSignals,hCOutPorts,nDims]=splitMatrix2SpecifiedDims(hN,hCInSignals,hCOutSignals,hCInPorts,hCOutPorts);
        need2ReDrawModelfromPir=true;
    end

    for i=1:nDims

        if needTreeArch(this,hC,hCInSignals(i),hCOutSignals(i))

            treeComp=getTreeArchitecture(this,hN,hN,hCInSignals(i),hCInPorts(i),...
            hCOutPorts(i),opName,rndMode,satMode,hC.Name,false,[],...
            int8(0),nfpOptions);

        else

            treeComp=pirelab.getDTCComp(hN,hCInSignals(i),hCOutSignals(i),rndMode,satMode);
        end


        out=hC.SLOutputSignals(1);
        numInputPorts=hC.NumberOfPirInputPorts;
        inputSigns=get_param(slbh,'Inputs');
        inputSigns=strrep(inputSigns,'|','');

        if targetmapping.mode(out)&&strcmp(inputSigns,'-')&&(numInputPorts==1)
            outSig=treeComp.PirOutputSignals(1);
            outType=outSig.Type;
            rcv=outSig.getReceivers;
            outSig.disconnectReceiver(rcv);

            sum_out=hN.addSignal(outType,[hC.Name,'_sum_out']);
            sum_out.SimulinkRate=outSig.SimulinkRate;
            sum_out.addReceiver(rcv);
            treeComp=pirelab.getUnaryMinusComp(hN,outSig,sum_out,satMode,[hC.Name,'_uminus']);
        end
    end

    if need2ReDrawModelfromPir


        hN.generateModelFromPir;
    end
end


