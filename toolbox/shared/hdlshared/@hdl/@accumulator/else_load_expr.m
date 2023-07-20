function hdlexpr=else_load_expr(this)







    for ii=1:length(this.load_val),
        hdlexpr{ii}.real=this.load_val_hdlconst{ii}.real;
    end
    if~isreal(this.load_val),
        for ii=1:length(this.load_val),
            hdlexpr{ii}.imag=this.load_val_hdlconst{ii}.imag;
        end
    end






