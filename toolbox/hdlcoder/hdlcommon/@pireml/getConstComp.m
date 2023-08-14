function constComp=getConstComp(hN,hOutSignals,constValue,compName)












    if nargin<4
        compName='const';
    end


    hT=hOutSignals(1).Type;
    if isempty(hT)
        return;
    end

    MatrixTypes=hT.isMatrix;

    if MatrixTypes
        if hT.is2DMatrix
            ipf='hdleml_matrixconst';
        else
            ipf='hdleml_3Dmatrixconst';
        end
        constValue=pirelab.getValueWithType(constValue,hT,true);
        outEx=pirelab.getTypeInfoAsFi(hOutSignals(1).Type);
        bmp={outEx,constValue};
    else
        ipf='hdleml_const';

        expandConst=isscalar(constValue);
        constValue=pirelab.getValueWithType(constValue,hT,expandConst);
        if hT.isArrayType&&~isvector(constValue)
            typeDims=hT.getDimensions;
            if hT.isRowVector
                typeDims=[1,typeDims];
            else
                typeDims=[typeDims,1];
            end
            constValue=reshape(constValue,typeDims);
        end
        bmp={constValue};
    end

    constComp=hN.addComponent2(...
    'kind','cgireml',...
    'Name',compName,...
    'InputSignals',[],...
    'OutputSignals',hOutSignals,...
    'EMLFileName',ipf,...
    'EMLParams',bmp,...
    'MatrixTypes',MatrixTypes);

    if targetmapping.isValidDataType(hOutSignals(1).Type)
        constComp.setSupportTargetCodGenWithoutMapping(true);
    end
end
