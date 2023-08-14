function mulComp=getMulComp(hN,hInSignals,hOutSignals,...
    rndMode,satMode,compName,inputSigns)












    if nargin<7||isempty(inputSigns)
        inputSigns='**';
    end

    if(nargin<6)||isempty(compName)
        if strcmp(inputSigns,'**')
            compName='multiplier';
        else
            compName='divider';
        end
    end

    if(nargin<5)||isempty(satMode)
        satMode='Wrap';
    end

    if(nargin<4)||isempty(rndMode)
        rndMode='Floor';
    end

    nDims=hOutSignals.Type.getDimensions;
    if strcmp(inputSigns,'*/')&&nDims>1


        if nDims>1&&hInSignals(2).Type.getDimensions==1
            inVec2=pirelab.scalarExpand(hN,hInSignals(2),nDims);
        else
            inVec2=hInSignals(2);
        end
        inVec1=pirelab.demuxSignal(hN,hInSignals(1));
        inVec2=pirelab.demuxSignal(hN,inVec2);
        outMux=pirelab.getMuxOnOutput(hN,hOutSignals(1));
        outVec=outMux.PirInputSignals;
        for ii=1:nDims
            mulComp=createMulComp(hN,[inVec1(ii),inVec2(ii)],outVec(ii),...
            rndMode,satMode,compName,inputSigns);
        end
    else
        mulComp=createMulComp(hN,hInSignals,hOutSignals,...
        rndMode,satMode,compName,inputSigns);
    end
end

function mulComp=createMulComp(hN,hInSignals,hOutSignals,...
    rndMode,satMode,compName,inputSigns)

    outTpEx=pirelab.getTypeInfoAsFi(hOutSignals.Type,rndMode,satMode);

    if strcmp(inputSigns,'**')||strcmp(inputSigns,'*')
        if length(hInSignals)==1
            ipf='hdleml_product_of_elements';
        else
            ipf='hdleml_product';
        end
        params={outTpEx};
        inSigs=hInSignals;
    elseif strcmp(inputSigns,'*/')
        ipf='hdleml_divide';
        inSigs=hInSignals;


        if strcmpi(rndMode,'Simplest')
            rndMode='Zero';
            outTpEx=pirelab.getTypeInfoAsFi(hOutSignals.Type,rndMode,satMode);
        end


        hInType1=hInSignals(1).Type;
        hInType2=hInSignals(2).Type;
        hOutType=hOutSignals.Type;


        if~(hInType1.isFloatType||hInType2.isFloatType||hOutType.isFloatType)
            outSigned=hOutType.Signed;
            outWordLen=hOutType.WordLength;
            outFracLen=-hOutType.FractionLength;

            resSigned=hInType1.Signed||hInType2.Signed;
            resWordLen=max(hInType1.WordLength,hInType2.WordLength);
            if resSigned
                resWordLen=resWordLen+1;
            end
            resFracLen=-hInType1.FractionLength+hInType2.FractionLength;



            if hInType1.Signed&&hInType2.Signed
                hT=pir_fixpt_t(true,hInType1.WordLength+1,hInType1.FractionLength);


                dtcOutSig=pireml.insertDTCCompOnInput(hN,hInSignals(1),hT,rndMode,satMode,compName);
                inSigs=[dtcOutSig,hInSignals(2)];
            end




            [need_outsat,divbyzero_outsat]=pirelab.handleExtraDivideByZeroLogic(...
            outSigned,outWordLen,outFracLen,resSigned,resWordLen,resFracLen,...
            hOutType,rndMode,satMode,outTpEx);
        else
            need_outsat=false;
            divbyzero_outsat=[];
        end

        params={outTpEx,need_outsat,divbyzero_outsat};
    else
        error(message('hdlcommon:hdlcommon:NotSupportedMode',inputSigns));
    end


    mulComp=hN.addComponent2(...
    'kind','cgireml',...
    'Name',compName,...
    'InputSignals',inSigs,...
    'OutputSignals',hOutSignals,...
    'EMLFileName',ipf,...
    'EMLParams',params);

    if strcmp(inputSigns,'*/')
        mulComp.runConcurrencyMaximizer(false);
    end

    if length(hInSignals)==1
        hT=hInSignals(1).Type;
        if hT.BaseType.isComplexType

            mulComp.runSSA(true);
        end
    end
end


