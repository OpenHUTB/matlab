function hdlcode=signalDecl(this)





    hdlcode=hdlcodeinit;

    if this.nDelays~=1
        for ii=1:length(this.outputs)
            decl=makehdlsignaldecl(this.outputs(ii));
            hdlcode.arch_signals=[hdlcode.arch_signals,decl];
        end
    end


