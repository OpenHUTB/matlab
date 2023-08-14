function dtcComp=getDTCComp(hN,hInSignals,hOutSignals,...
    roundMode,satMode,conversionMode,compName)




















    if(nargin<7)
        compName='dtc';
    end

    if(nargin<6)
        conversionMode='RWV';
    end

    if(nargin<5||isempty(satMode))
        satMode='Wrap';
    end

    if(nargin<4||isempty(roundMode))
        roundMode='Floor';
    end





    if strcmpi(conversionMode,'RWV')
        convModeVal=1;
    else
        convModeVal=2;
    end

    outTpEx=pirelab.getTypeInfoAsFi(hOutSignals(1).Type,roundMode,satMode);


    if hOutSignals(1).Type.getLeafType.isBooleanType
        outIsBool=1;
    else
        outIsBool=0;
    end

    isWireComp=false;
    if convModeVal==2
        outType=hOutSignals(1).Type.getLeafType;
        inType=hInSignals(1).Type.getLeafType;
        if(inType.isWordType&&outType.isWordType)
            isWireComp=inType.WordLength==outType.WordLength;
        end
    end


    pireml.checkSignalTypeValidity(hOutSignals,[hN.getNameForReporting,'/',compName]);

    dtcComp=hN.addComponent2(...
    'kind','cgireml',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'EMLFileName','hdleml_dtc_vector',...
    'EMLParams',{outTpEx,convModeVal,outIsBool},...
    'EMLFlag_RunLoopUnrolling',false);

    dtcComp.isWiringComp(isWireComp);

    if targetmapping.isValidDataType(hInSignals(1).Type)
        dtcComp.setSupportTargetCodGenWithoutMapping(true);
    end

end



