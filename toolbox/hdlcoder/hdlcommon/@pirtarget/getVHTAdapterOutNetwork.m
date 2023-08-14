function getVHTAdapterOutNetwork(hN,hStreamNetInportSignals,hStreamNetOutportSignals)






    pirelab.getWireComp(hN,hStreamNetInportSignals(1),hStreamNetOutportSignals(1),'data_out');
    pirelab.getWireComp(hN,hStreamNetInportSignals(6),hStreamNetOutportSignals(2),'user_valid');
    pirelab.getWireComp(hN,hStreamNetInportSignals(3),hStreamNetOutportSignals(3),'user_eol');
    pirelab.getWireComp(hN,hStreamNetInportSignals(4),hStreamNetOutportSignals(4),'user_sof');

end


