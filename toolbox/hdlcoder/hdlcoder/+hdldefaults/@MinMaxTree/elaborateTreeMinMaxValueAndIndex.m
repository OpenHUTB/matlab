function hNewC=elaborateTreeMinMaxValueAndIndex(this,hN,oldhN,blockInfo,blockDSPInfo,blockName)



    fcnString=blockInfo.fcnString;
    compType=blockInfo.compType;
    blockType=blockInfo.blockType;
    idxBase=blockInfo.idxBase;
    rndMode=blockInfo.rndMode;
    satMode=blockInfo.satMode;
    isDSP=blockInfo.isDSP;

    opName=compType;


    hInputPorts=hN.PirInputPorts;
    hOutputPorts=hN.PirOutputPorts;

    hCInSignal=hN.PirInputSignals(1);


    numInports=length(hInputPorts);
    dimLen=pirelab.getVectorTypeInfo(hCInSignal);


    if numInports~=1
        error(message('hdlcoder:validate:onlysupportoneinputport',blockName));
    end

    isIndexOnly=strcmpi(fcnString,'Index');


    if isIndexOnly
        hCOutSignal_Idx=hN.PirOutputSignals(1);
    else
        hCOutSignal_Val=hN.PirOutputSignals(1);
        hCOutSignal_Idx=hN.PirOutputSignals(2);
    end


    isDspVectorOut=this.isDspMinmaxVectorOut(blockDSPInfo,hCInSignal,blockType);

    if dimLen==1||isDspVectorOut




        indexType=hCOutSignal_Idx.Type.getLeafType;
        constIndexSignals=this.getIndexConstantComp(hN,dimLen,idxBase,indexType,isDspVectorOut);
        constIndexSignals.SimulinkRate=hCInSignal.SimulinkRate;

        if isIndexOnly
            hNewC=pirelab.getWireComp(hN,constIndexSignals,hCOutSignal_Idx);
        else
            hNewC=pirelab.getWireComp(hN,hCInSignal,hCOutSignal_Val);
            pirelab.getWireComp(hN,constIndexSignals,hCOutSignal_Idx);
        end

    else

        topNetInSignal=hN.PirInputSignals;
        topNetOutSignal=hN.PirOutputSignals;
        hNewNet=pirelab.createNewNetworkWithInterface(...
        'Network',hN,...
        'InputPorts',hInputPorts,'OutputPorts',hOutputPorts,'Name',blockName);


        needDetailedElab=needDetailedElaboration(this,oldhN,hN.PirInputSignals);
        pirelab.getTreeArch(hNewNet,hNewNet.PirInputSignals,hNewNet.PirOutputSignals,opName,rndMode,satMode,blockName,idxBase,false,needDetailedElab,isDSP,fcnString);


        for ii=1:length(topNetOutSignal)
            outsig=topNetOutSignal(ii);
            nwsig=hNewNet.PirOutputSignals(ii);
            nwsig.SimulinkRate=outsig.SimulinkRate;
        end


        hNewC=pirelab.instantiateNetwork(hN,hNewNet,topNetInSignal,topNetOutSignal,blockName);
        hNewNet.setFlattenHierarchy(hN.getFlattenHierarchy);
    end


