function hdlcode=endAsyncResetExpr(this)





    hdlcode=hdlcodeinit;

    if this.hasAsyncReset&&this.isVerilog
        hdlcode.arch_body_blocks=[hdl.indent(3),'end',hdl.newline];
    end
