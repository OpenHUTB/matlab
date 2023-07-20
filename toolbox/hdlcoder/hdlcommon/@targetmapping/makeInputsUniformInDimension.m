
function newInputSignals=makeInputsUniformInDimension(hN,hInSignals,compName)
    firstInputSignal=hInSignals(1);
    secondInputSignal=hInSignals(2);
    if firstInputSignal.Type.getDimensions==1&&secondInputSignal.Type.getDimensions>1

        muxOutSignal=targetmapping.muxInputSignal(hN,firstInputSignal,secondInputSignal.Type.getDimensions,compName);
        newInputSignals=[muxOutSignal,secondInputSignal];
    elseif firstInputSignal.Type.getDimensions>1&&secondInputSignal.Type.getDimensions==1

        muxOutSignal=targetmapping.muxInputSignal(hN,secondInputSignal,firstInputSignal.Type.getDimensions,compName);
        newInputSignals=[firstInputSignal,muxOutSignal];
    else
        newInputSignals=hInSignals;
    end
end

