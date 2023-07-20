function newComp=getAssignmentComp(hN,hInSignals,hOutSignal,...
    oneBasedIdx,idxOptionArray,idxParamArray,outputSizeArray,ndims,compName)


    if nargin<9
        compName='Assignment';
    end

    twoDims=strcmp(ndims,'2');

    inSigs=hInSignals;
    nfpMode=targetcodegen.targetCodeGenerationUtils.isNFPMode;

    oneBasedIndex=0;
    if strcmpi(oneBasedIdx,'One-based')
        oneBasedIndex=1;
    end
    if nfpMode
        if numel(inSigs)>2
            selSig=inSigs(3);
            selIsFloat=selSig.Type.getLeafType.isFloatType;
        else
            selIsFloat=false;
        end
        indims=hInSignals(1).Type.Dimensions;
        numElem=indims(1);
        if selIsFloat
            floatConvSig=pirelab.insertFloat2IdxDTCCompOnInput(hN,selSig,...
            numElem,oneBasedIndex,compName);
            inSigs(3)=floatConvSig;
        end
        if twoDims
            if numel(inSigs)>3
                selSig=inSigs(4);
                selIsFloat=selSig.Type.getLeafType.isFloatType;
            else
                selIsFloat=false;
            end
            if selIsFloat
                numElem=indims(2);
                floatConvSig=pirelab.insertFloat2IdxDTCCompOnInput(hN,selSig,...
                numElem,oneBasedIndex,compName);
                inSigs(4)=floatConvSig;
            end
        end
    end

    in1Type=inSigs(1).Type;
    in2Type=inSigs(2).Type;
    inBaseT=in1Type.BaseType;
    if twoDims&&inBaseT.isComplexType
        inLeafT=inBaseT.BaseType;
        in1Dim=in1Type.Dimensions;
        if in1Type.isRowVector
            in1Dim=[1,in1Dim];
        elseif in1Type.isColumnVector
            in1Dim=[in1Dim,1];
        end
        hArrayT=pirelab.createPirArrayType(inLeafT,in1Dim);

        in1Name=inSigs(1).Name;
        hRealIn=hN.addSignal(hArrayT,[in1Name,'_real']);
        hRealIn.SimulinkRate=inSigs(1).SimulinkRate;
        hImagIn=hN.addSignal(hArrayT,[in1Name,'_imag']);
        hImagIn.SimulinkRate=inSigs(1).SimulinkRate;
        pirelab.getComplex2RealImag(hN,inSigs(1),[hRealIn,hImagIn]);


        if in2Type.isArrayType
            in2Dim=in2Type.Dimensions;
            if in2Type.isRowVector
                in2Dim=[1,in2Dim];
            elseif in2Type.isColumnVector
                in2Dim=[in2Dim,1];
            end
            in2realType=pirelab.createPirArrayType(inLeafT,in2Dim);
        else
            in2realType=inLeafT;
        end
        in2Name=inSigs(2).Name;
        hRealNew=hN.addSignal(in2realType,[in2Name,'_real']);
        hImagNew=hN.addSignal(in2realType,[in2Name,'_imag']);
        pirelab.getComplex2RealImag(hN,inSigs(2),[hRealNew,hImagNew]);


        outName=hOutSignal(1).Name;
        hRealOut=hN.addSignal(hArrayT,[outName,'_real']);
        hRealOut.SimulinkRate=hOutSignal.SimulinkRate;
        hImagOut=hN.addSignal(hArrayT,[outName,'_imag']);
        hImagOut.SimulinkRate=hOutSignal.SimulinkRate;
        pirelab.getRealImag2Complex(hN,[hRealOut,hImagOut],hOutSignal);


        newComp=pircore.getAssignmentComp(hN,[hRealIn;hRealNew;inSigs(3:end)],...
        hRealOut,oneBasedIdx,ndims,idxParamArray,...
        idxOptionArray,outputSizeArray,compName);
        pircore.getAssignmentComp(hN,[hImagIn;hImagNew;inSigs(3:end)],...
        hImagOut,oneBasedIdx,ndims,idxParamArray,...
        idxOptionArray,outputSizeArray,compName);
    else
        newComp=pircore.getAssignmentComp(hN,inSigs,hOutSignal,...
        oneBasedIdx,ndims,idxParamArray,...
        idxOptionArray,outputSizeArray,compName);
    end
end
