function hdlcode=processEndExpr(this)





    hdlcode=hdlcodeinit;

    if this.isVHDL
        hdlcode.arch_body_blocks=...
        [hdl.indent(1),'END PROCESS ',this.processName,';'];
    else
        hdlcode.arch_body_blocks=...
        [hdl.indent(2),'end // ',this.processName];
    end
    hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,hdl.newline(1)];
