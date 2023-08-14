function hdlcode=postBody(this)





    hdlcode=hdlcodeinit;

    if this.outputpipelevels>0
        bodystr=hdldatatypeassignment(this.outputs(end),this.finalout,this.roundmode,this.saturation,'all');
        bodystr=strrep(bodystr,'\n\n',hdl.newline);
        hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,hdl.newline,bodystr,hdl.newline];
    else
        [bodystr,sigs]=hdlmultiply(this.areg(end),this.breg(end),this.finalout,this.roundmode,this.saturation,false);
        bodystr=strrep(bodystr,'\n\n',hdl.newline);
        hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,hdl.newline,bodystr,hdl.newline];
        hdlcode.arch_signals=[hdlcode.arch_signals,sigs];
    end


