function reshapeComp=getReshapeComp(hN,hInSignals,hOutSignals,outDimType,outDims,compName)


    narginchk(6,6);

    type=hInSignals(1).Type.BaseType;
    if type.isEnumType

        outEx=pirelab.getTypeInfoAsFi(hOutSignals(1).Type,'Floor','Wrap',0);
    else
        outEx=pirelab.getTypeInfoAsFi(hOutSignals(1).Type);
    end

    matrixTypes=hInSignals.Type.isMatrix||hOutSignals.Type.isMatrix;


    if hInSignals.Type.NumberOfDimensions==1&&hOutSignals.Type.NumberOfDimensions==3

        emlfile='hdleml_reshape1Dto3D';
    elseif hInSignals.Type.NumberOfDimensions==3&&hOutSignals.Type.NumberOfDimensions==1

        emlfile='hdleml_reshape3Dto1D';
    elseif hInSignals.Type.NumberOfDimensions==3&&hOutSignals.Type.NumberOfDimensions==2

        emlfile='hdleml_reshape3Dto2D';
    elseif hInSignals.Type.NumberOfDimensions==2&&hOutSignals.Type.NumberOfDimensions==3

        emlfile='hdleml_reshape2Dto3D';
    else

        emlfile='hdleml_reshape';
    end


    reshapeComp=hN.addComponent2(...
    'kind','cgireml',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'EMLFileName',emlfile,...
    'EMLParams',{outEx},...
    'EMLFlag_ParamsFollowInputs',false,...
    'EMLFlag_RunLoopUnrolling',false,...
    'MatrixTypes',matrixTypes);

    if targetmapping.isValidDataType(hInSignals(1).Type)
        reshapeComp.setSupportTargetCodGenWithoutMapping(true);
    end

end

