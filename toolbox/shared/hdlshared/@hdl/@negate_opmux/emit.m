function hdlcode=emit(this,in,sel,out,negate_string)



























    hdlcode=hdlcodeinit;

    in=this.in;
    out=this.out;
    sel=this.sel;
    negate_string=this.negate_string;


    expand_in=hdlexpandvectorsignal(in);
    expand_out=hdlexpandvectorsignal(out);
    expand_sel=hdlexpandvectorsignal(sel);
    copies=length(expand_in);

    if isscalar(expand_sel),
        expand_sel=repmat(sel,[copies,1]);
    end

    body=[];

    out_sltype=hdlsignalsltype(expand_out(1));
    out_vtype=hdlblockdatatype(out_sltype);

    [~,negin_idx]=hdlnewsignal(negate_string,'block',-1,0,copies,out_vtype,out_sltype);
    expand_negin=hdlexpandvectorsignal(negin_idx);

    signals=makehdlsignaldecl(negin_idx);

    for ii=1:copies,
        [tmpbody,tmpsigs]=hdlunaryminus(expand_in(ii),expand_negin(ii),this.rounding,this.saturation);
        body=[body,tmpbody,hdlmux([expand_in(ii),expand_negin(ii)],expand_out(ii),expand_sel(ii),{'='},0,'when-else'),'\n'];
        signals=[signals,tmpsigs];
    end




    hdlcode.arch_signals=[hdlcode.arch_signals,signals];
    hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,body];
