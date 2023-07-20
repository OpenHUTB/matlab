function hdlexpr=if_load_expr(this)







    addend1exp=hdlexpandvectorsignal(this.addend1);
    addend2exp=hdlexpandvectorsignal(this.addend2);

    cplx=hdlsignaliscomplex(this.addend1);
    hdlexpr={};
    for ii=1:length(addend1exp),
        hdlexpr{ii}.real=hdl.sum_expr(addend1exp(ii),addend2exp(ii),this.sum_type);
        if cplx,
            hdlexpr{ii}.imag=hdl.sum_expr(hdlsignalimag(addend1exp(ii)),hdlsignalimag(addend2exp(ii)),...
            this.sum_type);
        end
    end
