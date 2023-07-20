
function newInputSignals=makeInputSameDimensionAsOutput(hN,hInSignals,hOutSignals,compName)



    inputSignal=hInSignals(1);
    outputSignal=hOutSignals(1);
    if all(inputSignal.Type.getDimensions==1)&&any(outputSignal.Type.getDimensions>1)

        if sum(outputSignal.Type.getDimensions>1)==1

            newInputSignals=targetmapping.getVectorConcatComp(hN,inputSignal,outputSignal,compName);
        else


            intermediateInputSignal=targetmapping.getVectorConcatComp(hN,inputSignal,outputSignal,compName);
            newInputSignals=hN.addSignal(outputSignal.Type,inputSignal.Name);
            pirelab.getReshapeComp(hN,intermediateInputSignal,newInputSignals,compName);
        end
    else
        newInputSignals=hInSignals;
    end
end


