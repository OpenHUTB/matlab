function hdlcode=signalDecl(this)





    hdlcode=hdlcodeinit;

    if this.inputpipelevels>0
        for ii=1:numel(this.areg)
            hdlcode.arch_signals=[hdlcode.arch_signals,makehdlsignaldecl(this.areg(ii))];
        end

        for ii=1:numel(this.breg)
            hdlcode.arch_signals=[hdlcode.arch_signals,makehdlsignaldecl(this.breg(ii))];
        end
    end

    if this.outputpipelevels>0
        for ii=1:numel(this.mreg)
            hdlcode.arch_signals=[hdlcode.arch_signals,makehdlsignaldecl(this.mreg(ii))];
        end
    end

