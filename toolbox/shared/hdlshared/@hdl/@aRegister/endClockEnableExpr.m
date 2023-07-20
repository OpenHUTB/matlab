function hdlcode=endClockEnableExpr(this)





    hdlcode=hdlcodeinit;

    if this.hasClockEnable
        if this.isVHDL
            hdlcode.arch_body_blocks=[hdl.indent(3),'END IF;',hdl.newline];
        else
            hdlcode.arch_body_blocks=[hdl.indent(4),'end',hdl.newline];
        end
    end
