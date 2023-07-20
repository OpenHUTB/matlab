function hdlcode=postBody(this)





    hdlcode=hdlcodeinit;

    if~isempty(this.CounterSignal)
        hdlcode.arch_body_blocks=[hdl.newline...
        ,hdldatatypeassignment(this.outputs,this.CounterSignal,'Floor',0)];
    end


