function hdlcode=bodyExpr(this)





    hdlcode=hdlcodeinit;

    if this.isVHDL
        bodyIndent=3;
    else
        bodyIndent=4;
    end



    for ii=1:length(this.outputs)
        vect=max(hdlsignalvector(this.outputs(ii)));
        range=0:max(vect)-1;
        bodystr=hdlsignalassignment(this.inputs(ii),this.outputs(ii),range,range,[]);
        bodystr=strrep(bodystr,'\n\n  ',[hdl.newline,hdl.indent(bodyIndent+1)]);
        bodystr=strrep(bodystr,'\n\n',hdl.newline);
        hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,...
        hdl.indent(bodyIndent),bodystr];
    end


