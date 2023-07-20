function fl=getfilterlengths(this)






    coeffs=this.coefficients;
    dlist_modifier=find(coeffs);
    firlen=length(coeffs);

    fl.partitionlen=firlen;
    fl.firlen=firlen;
    fl.coeff_len=firlen;
    fl.czero_len=length(dlist_modifier);
    fl.dalen=fl.czero_len;

