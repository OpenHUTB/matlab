function hNewC=elaborate(~,hN,hC)




    maskvar=get_param(hC.SimulinkHandle,'MaskWSVariables');
    op=maskvar(arrayfun(@(x)strcmp(x.Name,'relop'),maskvar)).Value;
    constval=maskvar(arrayfun(@(x)strcmp(x.Name,'const'),maskvar)).Value;

    hSignalsIn=hC.SLInputSignals;
    pirType=hSignalsIn.Type.BaseType;
    constval=pirelab.getTypeInfoAsFi(pirType,'Nearest','Saturate',constval);
    [alwaysZero,alwaysOne,constval]=isKnownResult(constval,pirType,op);

    compName=hC.Name;
    if alwaysZero
        hNewC=pirelab.getConstComp(hN,hC.SLOutputSignals,0,compName);
    elseif alwaysOne
        hNewC=pirelab.getConstComp(hN,hC.SLOutputSignals,1,compName);
    else
        isConstZero=isequal(zeros(size(constval)),constval);
        hNewC=pirelab.getCompareToValueComp(hN,hSignalsIn,hC.SLOutputSignals,...
        op,constval,compName,isConstZero);
    end
end


function[alwaysZero,alwaysOne,roundedConst]=...
    isKnownResult(constval,pirType,opName)
    alwaysZero=false;
    alwaysOne=false;
    roundedConst=constval;
    [lowerBound,upperBound]=pirelab.getTypeBounds(pirType);
    if isempty(lowerBound)||isempty(upperBound)
        return;
    end

    overflow=all(constval>upperBound);
    underflow=all(constval<lowerBound);

    switch opName
    case{'<'}
        alwaysOne=overflow;
        alwaysZero=underflow;
    case{'<='}
        alwaysOne=overflow||all(constval>=upperBound);
        alwaysZero=underflow;
    case{'>'}
        alwaysZero=overflow;
        alwaysOne=underflow;
    case{'>='}
        alwaysZero=overflow;
        alwaysOne=underflow||all(constval<=lowerBound);
    case{'=='}
        alwaysZero=overflow||underflow||...
        (all(constval==lowerBound)&&all(constval==upperBound));
    case{'~='}
        alwaysOne=overflow||underflow;
    end

    if~alwaysOne&&~alwaysZero
        for ii=1:length(constval)
            if constval(ii)<=lowerBound
                roundedConst(ii)=lowerBound;
            elseif constval(ii)>=upperBound
                constval(ii)=upperBound;
            end
        end
    end
end
