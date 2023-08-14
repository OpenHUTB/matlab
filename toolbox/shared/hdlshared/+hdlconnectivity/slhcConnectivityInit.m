function slhcConnectivityInit(hPIR)











    hD=hdlcurrentdriver;
    hD.MCPinfo=[];





    if hdlgetparameter('multicyclepathinfo')
        msg1=message('hdlcoder:validate:MulticyclePathInfoCLIMessage');
        warnObj=message('hdlcoder:validate:MulticyclePathInfoDeprecate',msg1.getString);
        warning(warnObj);
    end




    if hdlgetparameter('multicyclepathinfo')&&hPIR.hasMultipleDataRates,

        hB=hdlconnectivity.tableHDLConnectivityBuilder;



        hCD=hdlconnectivity.getConnectivityDirector(...
        hdlconnectivity.slhcHDLConnectivityDirector('builder',hB));


        pUtil=hdlconnectivity.hdlpathutil('pir',hPIR,'pathDelim','.');

        hCD.setPathUtil(pUtil);

        tUtil=hdlconnectivity.slhcHDLtimingutil('pir',hPIR);
        hCD.setTimingUtil(tUtil);


        hdlconnectivity.genConnectivity(true);


        hdlconnectivity.tempNetName([]);
    else

        hdlconnectivity.genConnectivity(false);
    end


