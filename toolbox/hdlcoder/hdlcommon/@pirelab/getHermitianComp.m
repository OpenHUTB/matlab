function hcComp=getHermitianComp(hN,hInSignals,hOutSignals,satMode,compName,outSigType)




    if(nargin<5)
        compName='hermitian';
    end

    if(nargin<6)
        outSigType='auto';
    end


    isInputValid=targetmapping.isValidDataType(hInSignals.Type);
    isOutputValid=targetmapping.isValidDataType(hOutSignals.Type);

    if isInputValid||isOutputValid
        hcComp=NFPDetailedImpl(hN,compName,hInSignals,hOutSignals,outSigType);
    else
        hcComp=pircore.getHermitianComp(hN,hInSignals,hOutSignals,satMode,compName);
    end

end

function hcComp=NFPDetailedImpl(hN,compName,hInSignals,hOutSignals,outSigOption)


    [dimLenIn,baseTypeIn]=pirelab.getVectorTypeInfo(hInSignals,true);
    [dimLenOut,baseTypeOut]=pirelab.getVectorTypeInfo(hOutSignals,true);


    if hInSignals.Type.isArrayType
        inSigType=pirelab.createPirArrayType(baseTypeIn.BaseType,dimLenIn);
        outSigType=pirelab.createPirArrayType(baseTypeOut.BaseType,dimLenOut);
    else
        inSigType=baseTypeIn.BaseType;
        outSigType=baseTypeOut.BaseType;
    end

    complexCheckFlag=baseTypeIn.isComplexType;

    if complexCheckFlag


        realSigIn=hN.addSignal(inSigType,[compName,'_real_in']);
        realSigOut=hN.addSignal(outSigType,[compName,'_real_out']);
        imagSigIn=hN.addSignal(inSigType,[compName,'_imag_in']);
        imagSigConj=hN.addSignal(inSigType,[compName,'_imag_conj']);
        imagSigOut=hN.addSignal(outSigType,[compName,'_imag_out']);


        pirelab.getComplex2RealImag(hN,hInSignals,[realSigIn;imagSigIn]);
        pirelab.getUnaryMinusComp(hN,imagSigIn,imagSigConj);


        pirelab.getTransposeComp(hN,realSigIn,realSigOut,[compName,'_real_transpose']);
        pirelab.getTransposeComp(hN,imagSigConj,imagSigOut,[compName,'_imag_transpose']);

        hcComp=pirelab.getRealImag2Complex(hN,[realSigOut;imagSigOut],hOutSignals);
    else

        if any(strcmp(outSigOption,{'auto','real'}))



            hcComp=pirelab.getTransposeComp(hN,hInSignals,hOutSignals,[compName,'_real_transpose']);
        else

            realSigOut=hN.addSignal(outSigType,[compName,'_real_out']);

            pirelab.getTransposeComp(hN,hInSignals,realSigOut,[compName,'_real_transpose']);
            hcComp=pirelab.getRealImag2Complex(hN,realSigOut,hOutSignals,'real');
        end
    end
end

