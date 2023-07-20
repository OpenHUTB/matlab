function[hNewNet,hNewC]=replaceCompWithNtwk(this,hN,hC)





    hDriver=hdlcurrentdriver;
    hPir=hDriver.PirInstance;
    refSLBlock=hC.SimulinkHandle;
    hNewNet=hPir.addNetwork;
    hNewNet.SimulinkHandle=-1;
    hNewNet.FullPath=getfullname(hC.SimulinkHandle);
    hNewNet.Name=getfullname(hC.SimulinkHandle);


    blkName=get_param(refSLBlock,'Name');
    desc=get_param(refSLBlock,'Description');
    if~strcmp(desc,'')
        comment=hdlformatcomment(['Simulink model description for ',blkName,':']);
        hNewNet.addComment(comment);
        comment=hdlformatcomment(desc,2);
        hNewNet.addComment(comment);
    end


    inPortNames=this.InputPortNames;
    outPortNames=this.OutputPortNames;
    inPort=hC.SLInputPorts;
    outPort=hC.SLOutputPorts;

    for ii=1:length(inPort)
        newPort=hNewNet.addInputPort(inPortNames{ii});
        blockCompPort=inPort(ii);
        newPort.copySLDataFrom(blockCompPort);

        insig=blockCompPort.Signal;
        hsig=hNewNet.addSignal;

        hsig.Name=inPortNames{ii};
        hsig.Type=insig.Type;
        hsig.VType(insig.VType);
        hsig.Imag(insig.Imag);
        hsig.SimulinkHandle=0;
        hsig.SimulinkRate=insig.SimulinkRate;
        hsig.addDriver(hNewNet,ii-1);
    end

    for ii=1:length(outPort)
        newPort=hNewNet.addOutputPort(outPortNames{ii});
        blockCompPort=outPort(ii);
        newPort.copySLDataFrom(blockCompPort);

        outsig=blockCompPort.Signal;
        hsig=hNewNet.addSignal;
        hsig.Name=outPortNames{ii};
        hsig.Type=outsig.Type;
        hsig.VType(outsig.VType);
        hsig.Imag(outsig.Imag);
        hsig.SimulinkHandle=0;
        hsig.SimulinkRate=outsig.SimulinkRate;
        hsig.addReceiver(hNewNet,ii-1);
    end

    hNetworkComp=hN.addComponent('ntwk_instance_comp',hNewNet);
    hNetworkComp.Name=[hC.Name];
    hNetworkComp.SimulinkHandle=refSLBlock;

    hNewC=hNetworkComp;
    hN.replaceComponent(hC,hNetworkComp);
