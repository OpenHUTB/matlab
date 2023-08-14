function elaborateCascadeSum(this,hN,hC)




    hCInSignal=hN.PirInputSignals(1);
    if(pirelab.hasComplexType(hCInSignal.Type))
        hInType=pirelab.getComplexType(hCInSignal.Type);
    else
        hInType=hCInSignal.Type.getLeafType;
    end


    hCOutSignal=hN.PirOutputSignals(1);
    if(pirelab.hasComplexType(hCOutSignal.Type))
        hOutType=pirelab.getComplexType(hCOutSignal.Type);
    else
        hOutType=hCOutSignal.Type.getLeafType;
    end


    slbh=hC.SimulinkHandle;

    [compType,accumType,rndMode,satMode]=getBlockInfo(this,slbh,hOutType);


    opName=compType;


    accumTypeEx=pirelab.getTypeInfoAsFi(accumType,rndMode,satMode);


    if strcmpi(compType,'sum')
        ipf='hdleml_add_vec';
        bmp={accumTypeEx};
    else
        error(message('hdlcoder:validate:unsupportedblockoption',this.localGetBlockName(slbh)));
    end


    if hInType.isEqual(accumType)
        inDtcSignal=hCInSignal;
    else
        inDimLen=max(hCInSignal.Type.getDimensions);
        inDtcType=pirelab.getPirVectorType(accumType,inDimLen);
        inDtcSignal=hN.addSignal(inDtcType,[hCInSignal.Name,'_dtc']);
        pirelab.getDTCComp(hN,hCInSignal,inDtcSignal,rndMode,satMode);
    end


    if hOutType.isEqual(accumType)
        outDtcSignal=hCOutSignal;
    else
        outDimLen=max(hCOutSignal.Type.getDimensions);
        outDtcType=pirelab.getPirVectorType(accumType,outDimLen);
        outDtcSignal=hN.addSignal(outDtcType,[hCOutSignal.Name,'_dtc']);
        pirelab.getDTCComp(hN,outDtcSignal,hCOutSignal,rndMode,satMode);
    end


    this.elabCascadeBlock(hN,hC,inDtcSignal,outDtcSignal,...
    ipf,bmp,opName);


    pirOutSigs=hN.PirOutputSignals;
    for ii=1:length(pirOutSigs)
        hN.PirOutputSignals(ii).SimulinkRate=hN.PirInputSignals(1).SimulinkRate;
    end


