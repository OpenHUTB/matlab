function hNewC=lowerRI2C(hN,hC)



    if(hC.getMode==1)



        hNewC=hC;
    else

        hNewC=pireml.getRealImag2Complex(...
        hN,...
        hC.PirInputSignals,...
        hC.PirOutputSignals,...
        hC.getMode,...
        hC.getConstantVal,...
        hC.Name);

    end

end
