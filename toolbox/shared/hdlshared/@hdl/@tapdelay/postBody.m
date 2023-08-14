function hdlcode=postBody(this)





    hdlcode=hdlcodeinit;

    if strcmpi(this.includeCurrent,'on')
        hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,hdl.newline(1)];

        if strcmpi(this.delayOrder,'newest')
            start=0;
            inrange=(0:this.nDelays-1);
            outrange=(1:this.nDelays);
        else
            start=this.nDelays;
            inrange=(0:this.nDelays-1);
            outrange=(0:this.nDelays-1);
        end
        bodystr=hdlsignalassignment(this.outputs,this.tmpsignal,inrange,outrange,[]);
        bodystr=strrep(bodystr,'\n\n',hdl.newline);
        hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,bodystr];

        bodystr=hdlsignalassignment(this.inputs,this.tmpsignal,[],start,[]);
        bodystr=strrep(bodystr,'\n\n',hdl.newline);
        hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,bodystr];
    end

    hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,hdl.newline(1)];
