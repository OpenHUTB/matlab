function[hNewNet,inSignal,outSignal]=addNewNetwork(this,hN,Name,inPort,outPort,refSLBlock,SLHandle,mode)%#ok





    if nargin<8
        mode='connect';
    end

    hDriver=hdlcurrentdriver;
    hPir=hDriver.PirInstance;

    hNewNet=hPir.addNetwork;
    hNewNet.SimulinkHandle=SLHandle;

    for ii=1:length(inPort)
        hNewNet.addInputPort(inPort(ii).Name);
        insig=inPort(ii);
        hsig=hNewNet.addSignal;
        hsig.Name=insig.Name;
        hsig.Type=insig.Type;
        hsig.VType(insig.VType);
        hsig.Imag(insig.Imag);
        hsig.SimulinkHandle=0;
        hsig.SimulinkRate=insig.SimulinkRate;
        hsig.addDriver(hNewNet,ii-1);
    end

    for ii=1:length(outPort)
        hNewNet.addOutputPort(outPort(ii).Name);
        outsig=outPort(ii);
        hsig=hNewNet.addSignal;
        hsig.Name=outsig.Name;
        hsig.Type=outsig.Type;
        hsig.VType(outsig.VType);
        hsig.Imag(outsig.Imag);
        hsig.SimulinkHandle=0;
        hsig.SimulinkRate=outsig.SimulinkRate;
        hsig.addReceiver(hNewNet,ii-1);
    end
    for ii=1:length(inPort)
        inSignal(ii)=hNewNet.PirInputPorts(ii).Signal;%#ok
    end

    for ii=1:length(outPort)
        outSignal(ii)=hNewNet.PirOutputPorts(ii).Signal;%#ok
    end


    if strcmp(mode,'connect')
        hNetworkComp=hN.addComponent('ntwk_instance_comp',hNewNet);

        this.connectHDLBlk(hNetworkComp,inPort,outPort);

        hNetworkComp.Name=hdluniquename(Name);
        hNetworkComp.SimulinkHandle=refSLBlock.SimulinkHandle;
    else
        hNewNet.Name=Name;
    end
