function hCs=getFIFOComp(hN,InSignals,OutSignals,fifoSize,fifoName,ramCorePrefix,statusOut,almost_full_thresh)



















    narginchk(6,8);

    if nargin<7
        statusOut=true;
    end

    if nargin<8
        almost_full_thresh=0;
    end


    info.fifo_size=fifoSize;
    info.address_size=ceil(log2(fifoSize));
    info.input_rate=1;
    info.output_rate=1;
    info.name=fifoName;
    info.ramCorePrefix=ramCorePrefix;

    info.num_on=false;
    info.rst_on=false;

    if statusOut
        info.empty_on=true;

        if almost_full_thresh==0
            info.full_on=true;
            info.afull_on=false;
        else
            info.full_on=false;
            info.afull_on=true;
            info.afull_threshold=almost_full_thresh;
        end

    else
        info.empty_on=false;
        info.full_on=false;
        info.afull_on=false;
    end


    FIFOInSignals=InSignals;
    FIFOOutSignals=OutSignals;


    dataInSignal=FIFOInSignals(1);
    dataOutSignal=FIFOOutSignals(1);
    nDimsIn=dataInSignal.Type.getDimensions;
    nDimsOut=dataOutSignal.Type.getDimensions;

    if~isequal(nDimsIn,nDimsOut)
        error(message('hdlcommon:workflow:MismatchDataPortDimension'));
    end

    if numel(nDimsIn)>1

        newNDims=prod(nDimsIn);
        newInType=pirelab.createPirArrayType(dataInSignal.Type.BaseType,newNDims);
        newOutType=pirelab.createPirArrayType(dataOutSignal.Type.BaseType,newNDims);

        newInSig=hN.addSignal(newInType,dataInSignal.Name);
        newInSig.SimulinkRate=dataInSignal.SimulinkRate;

        newOutSig=hN.addSignal(newOutType,dataOutSignal.Name);
        newOutSig.SimulinkRate=dataOutSignal.SimulinkRate;

        pirelab.getWireComp(hN,dataInSignal,newInSig);
        pirelab.getWireComp(hN,newOutSig,dataOutSignal);

        nDimsIn=newNDims;
        dataInSignal=newInSig;
        dataOutSignal=newOutSig;
    end

    if nDimsIn>1


        dataInSignal_vec=pirelab.demuxSignal(hN,dataInSignal);
        outMux=pirelab.getMuxOnOutput(hN,dataOutSignal);
        dataOutSignal_vec=outMux.PirInputSignals;


        hCs(nDimsIn)=outMux;

        for ii=1:nDimsIn
            FIFOInSignals(1)=dataInSignal_vec(ii);
            FIFOOutSignals(1)=dataOutSignal_vec(ii);


            if ii>1&&info.empty_on
                info.empty_on=false;
                info.full_on=false;
                info.afull_on=false;
                FIFOOutSignals=FIFOOutSignals(1);
            end


            hNet=pirelab.getFIFONetwork(hN,FIFOInSignals,FIFOOutSignals,info,ramCorePrefix);


            hCs(ii)=pirelab.instantiateNetwork(hN,hNet,FIFOInSignals,FIFOOutSignals,fifoName);
        end
    else


        hNet=pirelab.getFIFONetwork(hN,FIFOInSignals,FIFOOutSignals,info,ramCorePrefix);


        hCs=pirelab.instantiateNetwork(hN,hNet,FIFOInSignals,FIFOOutSignals,fifoName);
    end

end

