function hNewC=magnitude2FloatImpl(~,hN,blockComp,hInSignals,hOutSignals,nfpOptions,outSigType)








    [dimLen,baseTypeIn]=pirelab.getVectorTypeInfo(hInSignals);

    complexCheckFlag=baseTypeIn.isComplexType;


    if complexCheckFlag

        if hInSignals.Type.isArrayType
            internalSigType=pirelab.createPirArrayType(baseTypeIn.BaseType,dimLen);
        else
            internalSigType=hInSignals.Type.BaseType;
        end


        realSig1=hN.addSignal(internalSigType,[blockComp.Name,'_real_sig_before']);
        realSig2=hN.addSignal(internalSigType,[blockComp.Name,'_real_sig_after']);
        imagSig1=hN.addSignal(internalSigType,[blockComp.Name,'_imag_sig_before']);
        imagSig2=hN.addSignal(internalSigType,[blockComp.Name,'_imag_sig_after']);

        hNewC=pirelab.getComplex2RealImag(hN,hInSignals,[realSig1;imagSig1]);

        hNewC=pirelab.getMulComp(hN,[realSig1;realSig1],realSig2,'Floor','Wrap','multiplier','**','',-1,int8(0),nfpOptions);
        hNewC=pirelab.getMulComp(hN,[imagSig1;imagSig1],imagSig2,'Floor','Wrap','multiplier','**','',-1,int8(0),nfpOptions);




        if(strcmp(outSigType,'auto')||strcmp(outSigType,'real'))
            hNewC=pirelab.getAddComp(hN,[realSig2;imagSig2],hOutSignals,'Floor','Wrap','adder',[],'++','',-1,nfpOptions);
        else

            realSigOut=hN.addSignal(internalSigType,[blockComp.Name,'_real_out']);

            hNewC=pirelab.getAddComp(hN,[realSig2;imagSig2],realSigOut,'Floor','Wrap','adder',[],'++','',-1,nfpOptions);
            hNewC=pirelab.getRealImag2Complex(hN,realSigOut,hOutSignals,'real');
        end

    else



        if(strcmp(outSigType,'auto')||strcmp(outSigType,'real'))
            hNewC=pirelab.getMulComp(hN,[hInSignals;hInSignals],hOutSignals,'Floor','Wrap','multiplier','**','',-1,int8(0),nfpOptions);


        else

            if hInSignals.Type.isArrayType



                internalSigType=pirelab.createPirArrayType(baseTypeIn.BaseType,dimLen);
            else
                internalSigType=hInSignals.Type.BaseType;
            end


            realSigOut=hN.addSignal(internalSigType,[blockComp.Name,'_real_out']);

            hNewC=pirelab.getMulComp(hN,[hInSignals;hInSignals],realSigOut,'Floor','Wrap','multiplier','**','',-1,int8(0),nfpOptions);
            hNewC=pirelab.getRealImag2Complex(hN,realSigOut,hOutSignals,'real');
        end
    end

end

