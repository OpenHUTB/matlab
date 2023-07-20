function elaborateCascadeProduct(this,hN,hC)




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


    rndMode=get_param(slbh,'RndMeth');
    if strcmpi(get_param(slbh,'DoSatur'),'on')
        satMode='Saturate';
    else
        satMode='Wrap';
    end


    opName='product';


    outTypeEx=pirelab.getTypeInfoAsFi(hOutType,rndMode,satMode);


    ipf='hdleml_product_vec';
    bmp={outTypeEx};


    if hInType.isEqual(hOutType)
        inDtcSignal=hCInSignal;
    else
        inDimLen=max(hCInSignal.Type.getDimensions);
        inDtcType=pirelab.getPirVectorType(hOutType,inDimLen);
        inDtcSignal=hN.addSignal(inDtcType,[hCInSignal.Name,'_dtc']);
        pirelab.getDTCComp(hN,hCInSignal,inDtcSignal,rndMode,satMode);
    end



    this.elabCascadeBlock(hN,hC,inDtcSignal,hCOutSignal,ipf,bmp,opName);

    pirOutSigs=hN.PirOutputSignals;
    for ii=1:length(pirOutSigs)
        hN.PirOutputSignals(ii).SimulinkRate=hN.PirInputSignals(1).SimulinkRate;
    end


