function[hdlbody,hdlsignals]=hdlsrcinstantiation(this,component)




    if hdlgetparameter('isvhdl')
        [hdlbody,hdlsignals]=this.vhdlsrcinstantiation(component);
    else
        [hdlbody,hdlsignals]=this.verilogsrcinstantiation(component);
    end
