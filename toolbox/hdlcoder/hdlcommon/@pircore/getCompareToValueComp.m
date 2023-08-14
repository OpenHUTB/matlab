function hNewC=getCompareToValueComp(hN,hSignalsIn,hSignalsOut,opName,constVal,compName,isConstZero)



    hNewC=hN.addComponent2(...
    'kind','comparetoconst',...
    'SimulinkHandle',-1,...
    'name',compName,...
    'InputSignals',hSignalsIn,...
    'OutputSignals',hSignalsOut,...
    'OpName',opName,...
    'Constant',constVal,...
    'IsConstZero',isConstZero);

    doCompRoughSemanticsMaps(hNewC,opName,constVal);
end

function doCompRoughSemanticsMaps(hNewC,op,constval)%#ok<INUSD>

    expr=sprintf('0 %s constval',op);
    result=eval(expr);
    if(~any(result))
        hNewC.setRetimingSafety(1);
    else
        hNewC.setRetimingSafety(0);
    end
end