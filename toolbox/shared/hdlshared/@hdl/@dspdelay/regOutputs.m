function regOutputs(this)








    for ii=1:length(this.outputs)
        for jj=1:length(this.outputs{ii})
            hdlregsignal(this.outputs{ii}(jj));
        end
    end

