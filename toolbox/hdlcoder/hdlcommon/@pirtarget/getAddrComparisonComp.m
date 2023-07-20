function hC=getAddrComparisonComp(hN,hInSignals,hOutSignals,addrStart,addrLength,regID)









    addr_in=hInSignals(1);
    addr_match=hOutSignals(1);

    ufix1Type=pir_ufixpt_t(1,0);


    addr_lb=hN.addSignal(ufix1Type,sprintf('addr_lb_%s',regID));
    pirelab.getCompareToValueComp(hN,addr_in,addr_lb,'>=',addrStart);

    addr_ub=hN.addSignal(ufix1Type,sprintf('addr_ub_%s',regID));
    pirelab.getCompareToValueComp(hN,addr_in,addr_ub,'<=',addrStart+addrLength-1);


    hC=pirelab.getBitwiseOpComp(hN,[addr_lb,addr_ub],addr_match,'AND');

end


