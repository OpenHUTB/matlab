function hdlcode=bodyExpr(this)





    hdlcode=hdlcodeinit;

    if this.isVHDL
        bodyIndent=3;
    else
        bodyIndent=4;
    end


    if this.inputpipelevels>0
        apipe=[this.inputs(1),this.areg];
        for ii=1:numel(apipe)-1
            bodystr=hdlsignalassignment(apipe(ii),apipe(ii+1),[],[],[]);
            bodystr=strrep(bodystr,'\n\n  ',[hdl.newline,hdl.indent(bodyIndent+1)]);
            bodystr=strrep(bodystr,'\n\n',hdl.newline);
            hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,...
            hdl.indent(bodyIndent),bodystr];
        end

        bpipe=[this.inputs(2),this.breg];
        for ii=1:numel(apipe)-1
            bodystr=hdlsignalassignment(bpipe(ii),bpipe(ii+1),[],[],[]);
            bodystr=strrep(bodystr,'\n\n  ',[hdl.newline,hdl.indent(bodyIndent+1)]);
            bodystr=strrep(bodystr,'\n\n',hdl.newline);
            hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,...
            hdl.indent(bodyIndent),bodystr];
        end
    end

    if this.outputpipelevels>0
        hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,...
        hdl.newline,...
        hdl.mulExpr(this.areg(end),this.breg(end),this.mreg(1),this.realonly,bodyIndent+1),...
        hdl.newline];

        for ii=2:numel(this.mreg)
            bodystr=hdlsignalassignment(this.mreg(ii-1),this.mreg(ii),[],[],[]);
            bodystr=strrep(bodystr,'\n\n  ',[hdl.newline,hdl.indent(bodyIndent+1)]);
            bodystr=strrep(bodystr,'\n\n',hdl.newline);
            hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,...
            hdl.indent(bodyIndent),bodystr];
        end
    end

