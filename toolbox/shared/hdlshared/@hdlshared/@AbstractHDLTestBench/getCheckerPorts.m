function[rdenbPort,addrPort,donePort,hdlbody,hdlsignals]=getCheckerPorts(this,snk)







    hdlbody=[];
    hdlsignals=[];

    [insthdlbody,insthdlsignals]=this.hdlsrcinstantiation(snk);
    hdlbody=[hdlbody,insthdlbody];%#ok
    for i=1:length(insthdlsignals)
        hdlsignals=[hdlsignals,makehdlsignaldecl(insthdlsignals(i))];%#ok
    end

    rdenbPort=insthdlsignals(1);
    addrPort=insthdlsignals(2);
    donePort=insthdlsignals(3);