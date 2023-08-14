function hdlcode=postBody(this)





    hdlcode=hdlcodeinit;

    hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,hdl.newline];

    for nd=1:length(this.nDelays)
        dly=this.nDelays(nd);
        if dly==1||...
            dly==0
            iprange=[];
        else
            iprange=dly-1;
        end
        if dly==0


            op=this.inputs(nd);
        else
            op=this.outputs{nd};
        end
        if length(op)>1
            for ii=1:length(op)
                bodystr=hdlsignalassignment(op(ii),this.tmpsignal,iprange,ii-1,[]);
                bodystr=strrep(bodystr,'\n\n',hdl.newline);
                hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,bodystr];
            end
        elseif length(this.tmpsignal)>1



            bodystr=hdlsignalassignment(op,this.tmpsignal(nd),iprange,[],[]);
            bodystr=strrep(bodystr,'\n\n',hdl.newline);
            hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,bodystr];
        else
            bodystr=hdlsignalassignment(op,this.tmpsignal,iprange,[],[]);
            bodystr=strrep(bodystr,'\n\n',hdl.newline);
            hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,bodystr];
        end
    end

    hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,hdl.newline];
