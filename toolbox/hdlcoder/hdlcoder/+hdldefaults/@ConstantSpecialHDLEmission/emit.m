function hdlcode=emit(this,hC)




    hdlcode=hdlcodeinit;

    zval=this.getImplParams('Value');
    if isempty(zval)
        zval='z';
    end
    zval=zval(1);

    out=hC.PirOutputPorts(1).Signal;

    hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,...
    hdlvectorconstantspecialassign(out,zval)];

    hdlcode=hdlcodeconcat([this.emitBlockComments(hC),hdlcode]);



