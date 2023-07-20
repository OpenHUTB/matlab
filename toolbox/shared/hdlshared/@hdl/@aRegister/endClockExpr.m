function hdlcode=endClockExpr(this)





    hdlcode=hdlcodeinit;
    if this.isVHDL
        hdlcode.arch_body_blocks=[hdl.indent(2),'END IF;',hdl.newline];
    end
