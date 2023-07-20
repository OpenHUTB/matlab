function gainComp=getGainComp(hN,hInSignal,hOutSignal,gainFactor,...
    gainMode,constMultiplierOptimMode,roundMode,satMode,compName,...
    dspMode,TunableParamStr,TunableParamType,gainParamGeneric,nfpOptions,...
    traceComment,matMulKind)





    if nargin<16
        matMulKind='linear';
    end

    if nargin<15
        traceComment='';
    end

    if nargin<14
        nfpOptions.Latency=int8(0);
        nfpOptions.MantMul=int8(0);
        nfpOptions.Denormals=int8(0);
    end

    if nargin<13
        gainParamGeneric=false;
    end

    if nargin<12
        TunableParamType=[];
    end

    if nargin<11
        TunableParamStr='';
    end

    if nargin<10
        dspMode=int8(0);
    end

    if(nargin<9)
        compName='gain';
    end

    if(nargin<8)
        satMode='Wrap';
    end

    if(nargin<7)
        roundMode='Floor';
    end

    if(nargin<6)
        constMultiplierOptimMode=0;
    end

    if(nargin<5)
        gainMode=1;
    end

    matrixGain=numel(size(gainFactor))==2&&all(size(gainFactor)>1);
    inType=hInSignal.Type;
    inLeafType=inType.getLeafType;
    outType=hOutSignal.Type;

    nfpMode=targetcodegen.targetCodeGenerationUtils.isNFPMode;
    nfpFloats=nfpMode&&inLeafType.isFloatType;


    if constMultiplierOptimMode~=0&&nfpFloats

        constMultiplierOptimMode=0;
    end

    if gainMode==2
        unorderedVectorInput=inType.isArrayType&&~inType.isMatrix&&...
        ~inType.isRowVector&&~inType.isColumnVector;



        if unorderedVectorInput&&~outType.isArrayType

            hInSignal=pirelab.alignVectorOrientation(hN,hInSignal,1);
            inType=hInSignal.Type;
        elseif unorderedVectorInput&&outType.isMatrix

            hInSignal=pirelab.alignVectorOrientation(hN,hInSignal,2);
            inType=hInSignal.Type;
        end
    elseif gainMode==4



        if inType.isArrayType
            if(inType.isRowVector)||(matrixGain&&~inType.isColumnVector)
                hInSignal=pirelab.alignVectorOrientation(hN,hInSignal,2);
                inType=hInSignal.Type;
            end
        end

        if~outType.isArrayType

            if~isrow(gainFactor)
                gainFactor=gainFactor';
            end
        end
    end

    if(~isBooleanType(hInSignal.Type.getLeafType)&&isBooleanType(hOutSignal.Type.getLeafType)&&gainMode==1)


        hConstS=elabGainValToConstComp(hN,hInSignal.SimulinkRate,gainFactor,traceComment);
        hConstS.Name='GainConst';
        pirelab.getConstComp(hN,hConstS,gainFactor,'const','on',false,TunableParamStr);

        gainComp=pirelab.getLogicComp(hN,[hInSignal,hConstS],...
        hOutSignal,'and','LogicalOperator');
        return;
    end
    if gainMode>1&&...
        (nfpFloats||inType.isMatrix||outType.isMatrix||matrixGain)&&...
        strcmp(hdlfeature('MatrixMultiplyTransform'),'off')


        hConstS=elabGainValToConstComp(hN,hInSignal.SimulinkRate,gainFactor,traceComment);
        if~inType.isMatrix&&inType.isArrayType&&...
            ~(inType.isRowVector||inType.isColumnVector)
            gainSz=size(gainFactor);
            if matrixGain&&gainMode==3
                vecOrientation=2;
            elseif matrixGain&&gainMode==2
                vecOrientation=1;
            else
                vecOrientation=find(gainSz==inType.Dimensions);
            end
            hInSignal=pirelab.alignVectorOrientation(hN,hInSignal,vecOrientation);
        end
        switch gainMode
        case 2

            hInSignal=[hInSignal,hConstS];
        case 3

            hInSignal=[hConstS,hInSignal];
        case 4

            hInSignal=[hConstS,hInSignal];
        otherwise
            assert(gainMode<4,'unsupported matrix gain mode');
        end
        gainComp=pirelab.getMatrixMulComp(hN,hInSignal,hOutSignal,...
        roundMode,satMode,compName,dspMode,nfpOptions,matMulKind,traceComment);
    elseif((inType.isMatrix||outType.isMatrix)&&...
        strcmp(hdlfeature('MatrixMultiplyTransform'),'off'))

        hConstS=elabGainValToConstComp(hN,hInSignal.SimulinkRate,gainFactor,traceComment);
        gainComp=pirelab.getScalarMatrixMulComp(hN,[hConstS,hInSignal],...
        hOutSignal,roundMode,satMode,compName,dspMode,nfpOptions,...
        traceComment);
    else

        isPowerOfTwo=false;
        gfval=double(gainFactor);

        if~gainParamGeneric


            if all(gfval>=0)
                if all(gfval(:)==1)||all(gfval(:)==0)||hdlispowerof2(gfval)
                    constMultiplierOptimMode=1;
                end
                if hdlispowerof2(gfval)
                    isPowerOfTwo=true;
                end
            end
        end

        if targetmapping.mode(hInSignal)

            gainComp=targetmapping.getGainComp(hN,hInSignal,hOutSignal,...
            gainFactor,gainMode,constMultiplierOptimMode,roundMode,satMode,...
            compName,gainParamGeneric,isPowerOfTwo,...
            TunableParamStr,TunableParamType,nfpOptions,matMulKind);
        else
            gainComp=pircore.getGainComp(hN,hInSignal,hOutSignal,gainFactor,gainMode,...
            constMultiplierOptimMode,roundMode,satMode,compName,dspMode,...
            TunableParamStr,TunableParamType,nfpOptions,matMulKind);


            if strcmpi(class(gainComp),'hdlcoder.gain_comp')
                gainComp.setPowerOf2Gain(isPowerOfTwo);
            end
        end
    end
end

function hConstS=elabGainValToConstComp(hN,simulinkRate,gainFactor,traceComment)
    gainFactorEx=pirelab.convertInt2fi(gainFactor);
    [typename,typedata]=getslsignaltypefromval(gainFactorEx);
    hT=getpirsignaltype(typename.native,typedata.iscomplex,...
    typedata.dims);
    hConstS=hN.addSignal(hT,'MatrixGainConst');
    hConstS.SimulinkRate=simulinkRate;
    hC=pirelab.getConstComp(hN,hConstS,gainFactor);
    hC.addTraceabilityComment(traceComment);
end

