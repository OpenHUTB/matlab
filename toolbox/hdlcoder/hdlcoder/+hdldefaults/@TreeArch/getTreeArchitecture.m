function hNewC=getTreeArchitecture(this,hN,oldhN,hDTCSignals,hInPorts,hOutPorts,opName,rndMode,satMode,compName,inputNeedDTC,aggType,dspMode,nfpOptions)





    if(nargin<14)
        nfpOptions.Latency=int8(0);
        nfpOptions.MantMul=int8(0);
        nfpOptions.Denormals=int8(0);
    end

    if(nargin<13)
        dspMode=int8(0);
    end
    if(nargin<12)
        aggType=[];
    end
    if(nargin<11)
        inputNeedDTC=false;
    end

    for ii=1:length(hInPorts)
        hInSignals(ii)=hInPorts(ii).Signal;
    end

    for ii=1:length(hOutPorts)
        hOutSignals(ii)=hOutPorts(ii).Signal;
    end



    needDetailedElab=needDetailedElaboration(this,oldhN,hDTCSignals,dspMode);
    if needDetailedElab

        hNewC=pirelab.getTreeArch(hN,hDTCSignals,hOutSignals,opName,rndMode,satMode,compName,'Zero',false,needDetailedElab,false,'Value',dspMode,nfpOptions);
    else

        topNetInSignal=hDTCSignals;
        topNetOutSignal=hOutSignals;

        if(inputNeedDTC)
            hNewNet=pirelab.createNewNetworkWithInterface(...
            'Network',hN,...
            'InputPorts',hInPorts,'OutputPorts',hOutPorts,...
            'useDTC',inputNeedDTC,'AggregateType',aggType,'Name',compName);
        else
            hNewNet=pirelab.createNewNetworkWithInterface(...
            'Network',hN,...
            'InputPorts',hInPorts,'OutputPorts',hOutPorts,'Name',compName);
        end


        pirelab.getTreeArch(hNewNet,hNewNet.PirInputSignals,hNewNet.PirOutputSignals,opName,rndMode,satMode,compName,'Zero',false,needDetailedElab);


        for ii=1:length(topNetOutSignal)
            outsig=topNetOutSignal(ii);
            nwsig=hNewNet.PirOutputSignals(ii);
            nwsig.SimulinkRate=outsig.SimulinkRate;
        end


        hNewC=pirelab.instantiateNetwork(hN,hNewNet,topNetInSignal,topNetOutSignal,compName);
        hNewNet.setFlattenHierarchy(hN.getFlattenHierarchy);
    end

end
