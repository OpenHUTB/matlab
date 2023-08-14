function[hCInSignals,hCInPorts,hCOutSignals,hCOutPorts,nDims]=splitMatrix2SpecifiedDims(hN,hCInSignals,hCOutSignals,hCInPorts,hCOutPorts)



    nDims=1;
    narginchk(3,5);
    if nargin==3
        hCInPorts=[];
        hCOutPorts=[];
    end

    if~hCOutSignals(1).Type.isArrayType


        ht=hCInSignals(1).Type;
        hBaseT=ht.BaseType;

        arrayType=pirelab.createPirArrayType(hBaseT,prod(hCInSignals(1).Type.Dimensions));
        newSignal=hN.addSignal(arrayType,[hCInSignals(1).Name,'_reshape']);
        newSignal.SimulinkRate=hCInSignals(1).SimulinkRate;
        pirelab.getReshapeComp(hN,hCInSignals(1),newSignal);
        hCInSignals=newSignal;
    else

        nDims=hCInSignals(1).Type.Dimensions(1);

        if hCOutSignals(1).Type.isRowVector
            nDims=hCInSignals(1).Type.Dimensions(2);

            colsplit=hCInSignals.split;
            hCInSignals=colsplit.PirOutputSignals;
            hCInPorts=colsplit.PirOutputPorts;
        else

            [hCInPorts,hCInSignals]=splitMatrix2RowVectors(hN,hCInSignals);
        end
        outMux=pirelab.getMuxOnOutput(hN,hCOutSignals(1));
        hCOutSignals=outMux.PirInputSignals;
        hCOutPorts=outMux.PirInputPorts;
    end
end
