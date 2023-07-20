function adderComp=getAddComp(hN,hInSignals,hOutSignals,...
    rndMode,satMode,compName,accType,inputSigns)




    if nargin<8||isempty(inputSigns)
        inputSigns='++';
    end

    if(nargin<6)||isempty(compName)
        compName='adder';
    end

    if(nargin<5)||isempty(satMode)
        satMode='Wrap';
    end

    if(nargin<4)||isempty(rndMode)
        rndMode='Floor';
    end


    outTpEx=pirelab.getTypeInfoAsFi(hOutSignals.Type,rndMode,satMode);

    if(nargin<7)||isempty(accType)
        accumTpEx=outTpEx;
    else
        accumTpEx=pirelab.getTypeInfoAsFi(accType,rndMode,satMode);
    end


    if isfi(accumTpEx)
        pireml.checkSignalTypeValidity(accumTpEx(1),[hN.getNameForReporting,'/',compName]);
    end

    paramsFollowInputs=true;
    inSigs=hInSignals;
    if numel(inputSigns)>2

        if~all(inputSigns=='+')
            error(message('hdlcommon:hdlcommon:unsupported'));
        end
        ipf='hdleml_sum_of_vararg_elements';
        params={outTpEx,accumTpEx};
        paramsFollowInputs=false;
    elseif numel(inputSigns)==1
        if strcmp(inputSigns,'-')

            ipf='hdleml_minus_sum_of_elements';
        else

            ipf='hdleml_sum_of_elements';
        end
        params={outTpEx,accumTpEx};
    elseif strcmp(inputSigns,'++')
        ipf='hdleml_add_withcast';
        params={outTpEx,accumTpEx,needAccumType(outTpEx)};
    elseif strcmp(inputSigns,'+-')
        ipf='hdleml_sub_withcast';
        params={outTpEx,accumTpEx,needAccumType(outTpEx)};
    elseif strcmp(inputSigns,'-+')
        ipf='hdleml_sub_withcast';
        params={outTpEx,accumTpEx,needAccumType(outTpEx)};
        inSigs=[hInSignals(2),hInSignals(1)];
    elseif strcmp(inputSigns,'--')
        ipf='hdleml_subsub';
        params={outTpEx,accumTpEx,needAccumType(outTpEx)};
    else
        error(message('hdlcommon:hdlcommon:UnknownSumSigns',inputSigns));
    end


    adderComp=hN.addComponent2(...
    'kind','cgireml',...
    'Name',compName,...
    'InputSignals',inSigs,...
    'OutputSignals',hOutSignals,...
    'EMLFileName',ipf,...
    'EMLParams',params,...
    'EMLFlag_ParamsFollowInputs',paramsFollowInputs,...
    'EMLFlag_RunLoopUnrolling',false);
end

function result=needAccumType(outTpEx)
    if~isfi(outTpEx)
        result=0;
    else
        result=1;
    end
end


