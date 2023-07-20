function hdlcode=bodyExpr(this)





    hdlcode=hdlcodeinit;

    if this.isVHDL
        bodyIndent=3;
    else
        bodyIndent=4;
    end

    if strcmpi(this.delayOrder,'newest')
        start=0;
        inrange=(0:this.nDelays-2);
        outrange=(1:this.nDelays-1);
    else
        start=this.nDelays-1;
        inrange=(1:this.nDelays-1);
        outrange=(0:this.nDelays-2);
    end


    if this.nDelays==1
        bodystr=hdlsignalassignment(this.inputs,this.outputs,[],[],[]);
        bodystr=strrep(bodystr,'\n\n  ',[hdl.newline,hdl.indent(bodyIndent+1)]);
        bodystr=strrep(bodystr,'\n\n',hdl.newline);
        hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,hdl.indent(bodyIndent),bodystr];
    else
        bodystr=hdlsignalassignment(this.outputs,this.outputs,inrange,outrange,[]);
        bodystr=strrep(bodystr,'\n\n  ',[hdl.newline,hdl.indent(bodyIndent+1)]);
        bodystr=strrep(bodystr,'\n\n',hdl.newline);
        hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,hdl.indent(bodyIndent),bodystr];

        bodystr=hdlsignalassignment(this.inputs,this.outputs,[],start,[]);
        bodystr=strrep(bodystr,'\n\n  ',[hdl.newline,hdl.indent(bodyIndent+1)]);
        bodystr=strrep(bodystr,'\n\n',hdl.newline);
        hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,hdl.indent(bodyIndent),bodystr];
    end



