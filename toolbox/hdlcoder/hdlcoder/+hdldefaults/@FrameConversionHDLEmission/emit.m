function hdlcode=emit(this,hC)





    hdlcode=hdlcodeinit;

    in=hC.SLInputPorts(1).Signal;
    out=hC.SLOutputPorts(1).Signal;


    hdlcode.arch_body_blocks=hdlsignalassignment(in,out);


    hdlcode=hdlcodeconcat([this.emitBlockComments(hC),hdlcode]);



