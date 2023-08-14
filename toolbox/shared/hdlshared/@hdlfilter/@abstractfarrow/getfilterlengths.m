function fl=getfilterlengths(this)





    coeffs=this.Coefficients;

    firlen=size(coeffs,1);

    fl.firlen=firlen;
    fl.coeffs=coeffs;




