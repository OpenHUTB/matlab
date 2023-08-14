function hNewC=elaborate(this,hN,hC)


    hInSignals=hC.PirInputSignals;
    hOutSignal=hC.PirOutputSignals;
    isNFPMode=targetcodegen.targetCodeGenerationUtils.isNFPMode;

    if isNFPMode
        nfpOptions=this.getNFPBlockInfo;
        if isempty(getImplParams(this,'InputRangeReduction'))
            nfpOptions.ArgReduction=true;
        else
            nfpOptions.ArgReduction=false;
        end

        hOutLeafType=hOutSignal.Type.getLeafType;
        hOutCos=hN.addSignal(hOutLeafType,'cos');
        hOutSin=hN.addSignal(hOutLeafType,'sin');
        hNewC=pirelab.getTrigonometricComp(hN,hInSignals(2),[hOutSin,hOutCos],...
        hC.Name,-1,'sincos',nfpOptions);
        hOutMulCos=hN.addSignal(hOutLeafType,'mulcos');
        hOutMulSin=hN.addSignal(hOutLeafType,'mulsin');
        pirelab.getMulComp(hN,[hInSignals(1),hOutCos],hOutMulCos,...
        'Nearest','Saturate','MagMul','**','',-1,int8(0),nfpOptions);
        pirelab.getMulComp(hN,[hInSignals(1),hOutSin],hOutMulSin,...
        'Nearest','Saturate','MagMul','**','',-1,int8(0),nfpOptions);
        pirelab.getRealImag2Complex(hN,[hOutMulCos,hOutMulSin],...
        hOutSignal,'real and imag',0,'cos_j_sine');
    else
        fName='pol2cart';

        cordicInfo=this.getBlockInfo(hC.SimulinkHandle);

        outBaseType=hOutSignal.Type.baseType;
        outIm=hN.addSignal(outBaseType,'out_im');
        outRe=hN.addSignal(outBaseType,'out_re');

        hCordicOutSignals=[outRe,outIm];

        usePipelines=true;
        hCordicNet=pirelab.getSinCosCordicNetwork(hN,hInSignals,hCordicOutSignals,...
        cordicInfo,fName,usePipelines);


        hCordic=pirelab.instantiateNetwork(hN,hCordicNet,hInSignals,...
        hCordicOutSignals,hC.Name);


        hRI2C=pirelab.getRealImag2Complex(hN,hCordicOutSignals,hOutSignal);
        hNewC=hN.createModelgenPartition([hCordic,hRI2C],fName);
    end
end


