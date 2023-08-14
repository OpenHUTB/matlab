function fdhcConnectivityInit()














    if hdlgetparameter('multicyclepathinfo'),

        hB=hdlconnectivity.tableHDLConnectivityBuilder;



        hCD=hdlconnectivity.getConnectivityDirector(...
        hdlconnectivity.HDLConnectivityDirector('builder',hB));


        hCD.setPathDelim('.');

        tUtil=hdlconnectivity.fdhcHDLtimingutil();
        hCD.setTimingUtil(tUtil);


        hdlconnectivity.genConnectivity(true);


        hdlconnectivity.tempNetName([]);
    else

        hdlconnectivity.genConnectivity(false);
    end

end


