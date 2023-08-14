function preparePirtcForMcp(this,p,domain)






    hN=p.findTimingControllerNetworks;


    fixverilogtypes;


    hdlsharedTC=hdl.TimingController;


    setSystemClockBundle(hN,hdlsharedTC);


    oldNetwork=this.getCurrentNetwork;
    this.setCurrentNetwork(hN);


    hdlsharedTC.emit(domain);


    this.setCurrentNetwork(oldNetwork);
end


function fixverilogtypes
    if hdlgetparameter('isverilog')
        insignals=hdlinportsignals;
        for ii=1:length(insignals)
            hS=insignals(ii);
            vt=hdlgetparameter('base_data_type');
            hdlsignalsetvtype(hS,vt);
        end
        outsignals=hdloutportsignals;
        for ii=1:length(outsignals)
            hS=outsignals(ii);
            vt=hdlgetparameter('base_data_type');
            hdlsignalsetvtype(hS,vt);
        end
    end
end


function setSystemClockBundle(hN,hdlSharedTC)
    hdlSharedTC.tcinfo.clk=hN.getInputSignals('clock');
    hdlSharedTC.tcinfo.reset=hN.getInputSignals('reset');
    hdlSharedTC.tcinfo.clkenable=hN.getInputSignals('clock_enable');
end



