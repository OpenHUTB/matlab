function[roundingMode,saturateMode,nfpOptions,isComplex]=getBlockInfo(this,hC)





    slbh=hC.SimulinkHandle;
    roundingMode=get_param(slbh,'rndMeth');
    sat=get_param(slbh,'saturateOnIntegerOverflow');

    if strcmp(sat,'on')
        saturateMode='Saturate';
    else
        saturateMode='Wrap';
    end

    pirelab.getTypeInfoAsFi(hC.SLOutputSignals(1).Type,roundingMode,saturateMode);

    hInSignals=hC.PirInputSignals;


    [~,inBaseType]=pirelab.getVectorTypeInfo(hInSignals);
    isComplex=inBaseType.isComplexType;

    nfpOptions=this.getNFPBlockInfo;
end
