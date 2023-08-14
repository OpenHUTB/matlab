function hdlcode=asyncResetExpr(this)





    hdlcode=hdlcodeinit;

    if this.hasAsyncReset
        if this.isVHDL
            hdlcode.arch_body_blocks=...
            [hdl.indent(2),'IF ',hdlsignalname(this.asyncReset),' = ','''',int2str(this.resetAssertedLevel),'''',' THEN',hdl.newline];
        else
            hdlcode.arch_body_blocks=...
            [hdl.indent(3),'if (',hdlsignalname(this.asyncReset),' == 1''b',int2str(this.resetAssertedLevel),')',' begin',hdl.newline];
        end

    end

