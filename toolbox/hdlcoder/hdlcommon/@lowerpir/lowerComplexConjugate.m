
function hNewC=lowerComplexConjugate(hN,hC)



    hInSignals=hC.PirInputSignals;
    hOutSignals=hC.PirOutputSignals;
    satMode=hC.getSaturationMode();
    rndMode=hC.getRoundingMode();
    compName='conj';




    outputEx=pirelab.getTypeInfoAsFi(hInSignals.Type.getLeafType,rndMode,satMode);


    if hInSignals.Type.isArrayType&&hOutSignals.Type.isArrayType
        hInBaseType=hInSignals.Type.BaseType;
        hOutBaseType=hOutSignals.Type.BaseType;
    else
        hInBaseType=hInSignals.Type;
        hOutBaseType=hOutSignals.Type;
    end

    if~hInBaseType.isComplexType&&hOutBaseType.isComplexType
        complexOut=true;
    else
        complexOut=false;
    end


    hNewC=hN.addComponent2(...
    'kind','cgireml',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'EMLFileName','hdleml_complexconjugate',...
    'EMLParams',{outputEx,complexOut},...
    'EMLFlag_RunLoopUnrolling',false);
end
