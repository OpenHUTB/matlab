function hdlcode=postBody(this)





    hdlcode=hdlcodeinit;

    if this.nDelays>1
        if length(this.outputs)>1
            for ii=1:length(this.outputs)
                bodystr=hdlsignalassignment(this.outputs(ii),this.tmpsignal(ii),this.nDelays-1,[],[]);
                bodystr=strrep(bodystr,'\n\n',hdl.newline);
                hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,bodystr];
            end
        else
            bodystr=hdlsignalassignment(this.outputs,this.tmpsignal,this.nDelays-1,[],[]);
            bodystr=strrep(bodystr,'\n\n',hdl.newline);
            hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,bodystr];
        end
        hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,hdl.newline];
    end
