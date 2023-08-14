function hdlcode=syncResetExpr(this)





    hdlcode=hdlcodeinit;

    if this.hasSyncReset
        if this.isVHDL
            hdlcode.arch_body_blocks=...
            [hdl.indent(3),'IF ',hdlsignalname(this.syncReset),' = ','''',...
            int2str(this.resetAssertedLevel),'''',' THEN',hdl.newline];
        else
            hdlcode.arch_body_blocks=...
            [hdl.indent(3),'if (',hdlsignalname(this.syncReset),' == 1''b',...
            int2str(this.resetAssertedLevel),')',' begin',hdl.newline];
        end






    end

