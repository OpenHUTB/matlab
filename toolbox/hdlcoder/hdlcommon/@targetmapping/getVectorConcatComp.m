



function vectorConcatOutSignal=getVectorConcatComp(hN,inputSignal,outputSignal,compName)



    dimLen=prod(outputSignal.Type.getDimensions);
    hInSignals=repmat(inputSignal,dimLen,1);



    if outputSignal.Type.isRowVector
        vectorOrientation=1;
    elseif outputSignal.Type.isColumnVector
        vectorOrientation=2;
    else
        vectorOrientation=0;
    end


    vecConcatOutSigT=hN.getType('Array','BaseType',inputSignal.Type,...
    'Dimensions',dimLen,'VectorOrientation',vectorOrientation);


    vectorConcatOutSignal=hN.addSignal(vecConcatOutSigT,sprintf('%s_in_vectorConcatenate',compName));
    vectorConcatOutSignal.SimulinkRate=hInSignals(1).SimulinkRate;



    if outputSignal.Type.isRowVector
        pirelab.getConcatenateComp(hN,hInSignals,vectorConcatOutSignal,'Multidimensional array','2');
    elseif outputSignal.Type.isColumnVector
        pirelab.getConcatenateComp(hN,hInSignals,vectorConcatOutSignal,'Multidimensional array','1');
    else
        pirelab.getConcatenateComp(hN,hInSignals,vectorConcatOutSignal,'Vector','1');
    end
