function hNewC=lowerReshape(hN,hC)



    if hdlgetparameter('loop_unrolling')
        hNewC=pireml.getReshapeComp(...
        hN,...
        hC.PirInputSignals,...
        hC.PirOutputSignals,...
        hC.getOutputDimensionality,...
        hC.getOutputDimensions,...
        hC.Name);
    else
        if hC.PirOutputSignals(1).Type.isMatrix&&...
            hC.PirInputSignals(1).Type.isMatrix
            insertReshapeBefore(hN,hC,prod(hC.PirOutputSignals(1).Type.Dimensions));
            hNewC=hC;
        else
            hNewC=hC;
        end
    end

end
