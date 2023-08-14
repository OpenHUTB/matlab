function hdlcode=signalDecl(this)





    hdlcode=hdlcodeinit;

    if strcmpi(this.includeCurrent,'on')
        decl=makehdlsignaldecl(this.outputs);
        hdlcode.arch_signals=[hdlcode.arch_signals,decl];
    end


