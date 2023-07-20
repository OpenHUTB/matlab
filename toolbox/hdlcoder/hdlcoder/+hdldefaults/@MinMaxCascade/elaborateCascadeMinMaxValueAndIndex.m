function elaborateCascadeMinMaxValueAndIndex(this,hN,hC)




    slbh=hC.SimulinkHandle;

    [fcnString,compType,blockType,idxBase,rndMode,satMode]=this.getBlockInfo(slbh);

    opName=compType;
    casName=sprintf('---- Cascade %s implementation ----',opName);

    if strcmp(compType,'min')
        ipf='hdleml_min_valandidx';
    else
        ipf='hdleml_max_valandidx';
    end
    bmp={};


    numInports=length(hC.PirInputPorts);
    hCInSignal=hN.PirInputSignals(1);
    [dimLen,hcInType]=pirelab.getVectorTypeInfo(hCInSignal);


    if numInports~=1
        error(message('hdlcoder:validate:onlysupportoneinputport',localGetBlockName(slbh)));
    end


    if strcmpi(fcnString,'Value and Index')
        hCOutSignal_Val=hN.PirOutputSignals(1);
        hCOutSignal_Idx=hN.PirOutputSignals(2);
    elseif strcmpi(fcnString,'Index')
        hCOutSignal_Val=hN.addSignal(hcInType,'outmin');
        hCOutSignal_Idx=hN.PirOutputSignals(1);
    end


    isDspVectorOut=this.isDspMinmaxVectorOut(slbh,hCInSignal,blockType);

    if dimLen==1||isDspVectorOut

        indexType=hCOutSignal_Idx.Type.getLeafType;
        constIndexSignals=this.getIndexConstantComp(hN,dimLen,idxBase,indexType,isDspVectorOut);



        if strcmpi(fcnString,'Value and Index')
            valWire=pirelab.getWireComp(hN,hCInSignal,hCOutSignal_Val);


            valWire.copyComment(hC);

            pirelab.getWireComp(hN,constIndexSignals,hCOutSignal_Idx);
        elseif strcmpi(fcnString,'Index')
            pirelab.getWireComp(hN,constIndexSignals,hCOutSignal_Idx);
        end

    else

        indexType=pir_ufixpt_t(floor(log2(dimLen)+1),0);


        dtcInIdxSignal=this.insertDTCComp(hN,hC,indexType,hCOutSignal_Idx,rndMode,satMode);


        tSignalsOut=[hCOutSignal_Val,dtcInIdxSignal];


        this.cascadeExpandCgirComp_ValueAndIndex(hN,hC,opName,hcInType,ipf,bmp,hCInSignal,tSignalsOut,casName,indexType,idxBase);

    end

    pirOutSigs=hN.PirOutputSignals;
    for ii=1:length(pirOutSigs)
        hN.PirOutputSignals(ii).SimulinkRate=hN.PirInputSignals(1).SimulinkRate;
    end


