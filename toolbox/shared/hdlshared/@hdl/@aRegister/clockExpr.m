function hdlcode=clockExpr(this)





    hdlcode=hdlcodeinit;

    if this.isVHDL
        if this.hasAsyncReset
            hdlcode.arch_body_blocks=[hdl.indent(2),'ELSIF '];
        else
            hdlcode.arch_body_blocks=[hdl.indent(2),'IF '];
        end
        if this.useClockRisingEdge
            if this.hasNegEdgeClock
                hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,'falling_edge(',hdlsignalname(this.clock),')'];
            else
                hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,'rising_edge(',hdlsignalname(this.clock),')'];
            end
        else
            hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,hdlsignalname(this.clock),'''event AND ',...
            hdlsignalname(this.clock),' = '];
            if this.hasNegEdgeClock
                hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,'''0'''];
            else
                hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,'''1'''];
            end
        end
        hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,' THEN',hdl.newline];
    else
        if this.hasAsyncReset
            hdlcode.arch_body_blocks=...
            [hdl.indent(3),'end',hdl.newline,...
            hdl.indent(3),'else begin',hdl.newline];
        end
    end

