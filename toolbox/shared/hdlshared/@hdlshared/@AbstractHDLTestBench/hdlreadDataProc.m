function[hdlbody,hdlsignal]=hdlreadDataProc(this,rdenb,tbenb_dly,txdataCnt,instance,clkrate)


    if hdlgetparameter('isvhdl')
        [hdlbody,hdlsignal]=this.vhdlreadDataProc(rdenb,tbenb_dly,txdataCnt,instance,clkrate);
    else
        [hdlbody,hdlsignal]=this.verilogreadDataProc(rdenb,tbenb_dly,txdataCnt,instance,clkrate);
    end
