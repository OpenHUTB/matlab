function absComp=getAbsComp(hN,hInSignals,hOutSignals,roundingMode,satMode,compName,nfpOptions,isComplex)



    if(nargin<8)
        isComplex=false;
    end

    if(nargin<7)
        nfpOptions.Latency=int8(0);
        nfpOptions.MantMul=int8(0);
        nfpOptions.Denormals=int8(0);
    end

    if(nargin<6)
        compName='abs';
    end

    if(nargin<5)
        roundingMode='floor';
    end

    if(nargin<4)
        satMode='Wrap';
    end

    if isComplex

        [dimLen,baseTypeIn]=pirelab.getVectorTypeInfo(hInSignals);

        if hInSignals.Type.isArrayType
            baseType=pirelab.createPirArrayType(baseTypeIn.BaseType,dimLen);
        else
            baseType=hInSignals.Type.BaseType;
        end


        inReal=hN.addSignal(baseType,[compName,'_real']);
        inImag=hN.addSignal(baseType,[compName,'_imag']);

        absComp=pirelab.getComplex2RealImag(hN,hInSignals,[inReal;inImag]);

        absComp=pirelab.getMathComp(hN,[inReal;inImag],hOutSignals,[compName,'_hypot'],...
        -1,'hypot',nfpOptions);
    else
        absComp=pircore.getAbsComp(hN,hInSignals,hOutSignals,roundingMode,satMode,compName);
    end

end
