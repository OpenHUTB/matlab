function hdlcode=bodyExpr(this)





    hdlcode=hdlcodeinit;

    if this.isVHDL
        bodyIndent=3;
    else
        bodyIndent=4;
    end

    start=0;
    inrange=(0:this.nDelays-2);
    outrange=(1:this.nDelays-1);
    lenout=length(this.outputs);
    morethanone=lenout>1;

    if this.nDelays==1

        vect=max(hdlsignalvector(this.outputs));
        range=0:max(vect)-1;
        bodystr=hdlsignalassignment(this.inputs,this.outputs,range,range,[]);
        bodystr=strrep(bodystr,'\n\n  ',[hdl.newline,hdl.indent(bodyIndent+1)]);
        bodystr=strrep(bodystr,'\n\n',hdl.newline);
        hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,...
        hdl.indent(bodyIndent),bodystr];
    else
        for ii=1:lenout
            bodystr=hdlsignalassignment(this.outputs(ii),this.outputs(ii),inrange,outrange,[]);
            bodystr=strrep(bodystr,'\n\n  ',[hdl.newline,hdl.indent(bodyIndent+1)]);
            bodystr=strrep(bodystr,'\n\n',hdl.newline);
            hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,hdl.indent(bodyIndent),bodystr];

            if morethanone
                slice=ii-1;
            else
                slice=[];
            end
            bodystr=hdlsignalassignment(this.inputs(ii),this.outputs(ii),slice,start,[]);
            bodystr=strrep(bodystr,'\n\n  ',[hdl.newline,hdl.indent(bodyIndent+1)]);
            bodystr=strrep(bodystr,'\n\n',hdl.newline);
            hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,hdl.indent(bodyIndent),bodystr];
        end
    end
