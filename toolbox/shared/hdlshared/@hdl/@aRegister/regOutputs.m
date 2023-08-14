function regOutputs(this)





    for ii=1:length(this.outputs)
        hdlregsignal(this.outputs(ii))
    end

