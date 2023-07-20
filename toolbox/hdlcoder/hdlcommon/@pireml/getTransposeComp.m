function tpComp=getTransposeComp(hN,hInSignals,hOutSignals,compName)

    if(nargin<4)
        compName='transpose';
    end


    hOutT=hOutSignals.Type;
    if hOutT.isArrayType
        hOutBaseType=hOutT.BaseType;
    else
        hOutBaseType=hOutT;
    end

    complexOut=hOutBaseType.isComplexType;
    matrixTypes=hInSignals.Type.isMatrix;

    tpComp=hN.addComponent2(...
    'kind','cgireml',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'EMLFileName','hdleml_transpose',...
    'EMLParams',{complexOut},...
    'EMLFlag_RunLoopUnrolling',false,...
    'MatrixTypes',matrixTypes);

end

