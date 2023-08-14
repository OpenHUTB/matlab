function hNewC=elaborate(this,hN,hC)





    impl=getFunctionImpl(this,hC);


    if isempty(impl)
        blockInfo=getBlockInfo(this,hC);
        hC.Name='product';

        hInSignals=hC.PirInputSignals;
        hOutSignals=hC.PirOutputSignals;

        hNewC=pirelab.getShiftAddMulComp(hN,hInSignals,hOutSignals,blockInfo);
    else

        hNewC=impl.elaborate(hN,hC);
    end

end
