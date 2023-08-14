function hdlcode=bodyExpr(this)





    hdlcode=hdlcodeinit;

    if this.isVHDL
        bodyIndent=3;
    else
        bodyIndent=4;
    end

    for nd=1:length(this.nDelays)
        if(this.nDelays(nd)==0)
            continue;
        end

        dly=this.nDelays(nd);
        op=this.outputs{nd};
        if(length(this.inputs)>1)
            ip=this.inputs(nd);
        else
            ip=this.inputs(1);
        end
        start=0;
        inrange=(0:dly-2);
        outrange=(1:dly-1);
        lenout=length(op);
        morethanone=lenout>1;

        if this.nDelays(nd)==1
            for ii=1:lenout

                if morethanone
                    slice=ii-1;
                else
                    slice=[];
                end
                bodystr=hdlsignalassignment(ip,op(ii),slice,[],[]);
                bodystr=strrep(bodystr,'\n\n  ',[hdl.newline,hdl.indent(bodyIndent+1)]);
                bodystr=strrep(bodystr,'\n\n',hdl.newline);
                hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,hdl.indent(bodyIndent),bodystr];
            end
        else
            for ii=1:lenout

                if morethanone
                    slice=ii-1;
                else
                    slice=[];
                end
                bodystr=hdlsignalassignment(ip,op(ii),slice,start,[]);
                bodystr=strrep(bodystr,'\n\n  ',[hdl.newline,hdl.indent(bodyIndent+1)]);
                bodystr=strrep(bodystr,'\n\n',hdl.newline);
                hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,hdl.indent(bodyIndent),bodystr];

                bodystr=hdlsignalassignment(op(ii),op(ii),inrange,outrange,[]);
                bodystr=strrep(bodystr,'\n\n  ',[hdl.newline,hdl.indent(bodyIndent+1)]);
                bodystr=strrep(bodystr,'\n\n',hdl.newline);
                hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,hdl.indent(bodyIndent),bodystr];
            end
        end
    end
