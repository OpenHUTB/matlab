
function tpComp=lowerHermitianComp(hN,hC)


    hInSignals=hC.PirInputSignals;
    hOutSignals=hC.PirOutputSignals;
    satMode=hC.getSaturationMode();
    rndMode='floor';
    compName='hermitian';


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

    matrixTypes=hInSignals.Type.isMatrix;


    tpComp=hN.addComponent2(...
    'kind','cgireml',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'EMLFileName','hdleml_hermitian',...
    'EMLParams',{outputEx,complexOut},...
    'EMLFlag_RunLoopUnrolling',false,...
    'MatrixTypes',matrixTypes);
end
