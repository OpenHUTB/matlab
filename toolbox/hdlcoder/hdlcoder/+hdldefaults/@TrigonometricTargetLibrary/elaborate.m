function hNewC=elaborate(this,hN,blockComp)




    hInSignals=blockComp.PirInputSignals;
    hOutSignals=blockComp.PirOutputSignals;
    fname=get_param(blockComp.SimulinkHandle,'Function');
    nfpOptions=getNFPBlockInfo(this);

    if isempty(getImplParams(this,'InputRangeReduction'))
        nfpOptions.ArgReduction=true;
    else
        nfpOptions.ArgReduction=false;
    end

    nfpMantissaStrategy=getImplParams(this,'MultiplyStrategy');
    nfpOptions.MantMul=int8(0);

    if isempty(nfpMantissaStrategy)
        nfpOptions.MantMul=int8(0);
    elseif strcmpi(nfpMantissaStrategy,'FullMultiplier')
        nfpOptions.MantMul=int8(1);
    elseif strcmpi(nfpMantissaStrategy,'PartMultiplierPartAddShift')
        nfpOptions.MantMul=int8(2);
    end


    if strcmpi(fname,'cos + jsin')
        hNewC=build_complex_sincos(hN,hInSignals,hOutSignals,blockComp,nfpOptions);
    else
        hNewC=pirelab.getTrigonometricComp(hN,hInSignals,hOutSignals,...
        blockComp.Name,-1,fname,nfpOptions);
    end
end



function hNewC=build_complex_sincos(hN,hInSignals,hOutSignals,blockComp,nfpOptions)
    hOutType=hOutSignals.Type;
    hOutLeafType=hOutType.getLeafType;
    if hOutType.isArrayType
        dims=pirelab.getVectorTypeInfo(hOutSignals,true);
        hOutLeafType=pirelab.createPirArrayType(hOutLeafType,dims);
    end
    hOutSignals_Cos=hN.addSignal(hOutLeafType,'cos');
    hOutSignals_Sin=hN.addSignal(hOutLeafType,'sin');
    hNew_SinCos=pirelab.getTrigonometricComp(hN,hInSignals,[hOutSignals_Sin,hOutSignals_Cos],...
    blockComp.Name,-1,'sincos',nfpOptions);%#ok<NASGU>    
    hNewC=pirelab.getRealImag2Complex(hN,[hOutSignals_Cos,hOutSignals_Sin],hOutSignals,'real and imag',0,'cos_j_sine');

end
