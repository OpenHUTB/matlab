function fl=getfilterlengths(this)





    coeffs=this.coefficients;
    dlist_modifier=find(coeffs);
    firlen=length(coeffs);
    oddtaps=mod(firlen,2);

    if oddtaps==0
        coeff_len=firlen/2;
    else
        if strcmpi(this.class,'hdlfilter.dfasymfir')&&firlen~=1


            coeff_len=floor(firlen/2);
        else

            coeff_len=floor(firlen/2)+1;
        end
    end

    if mod(length(dlist_modifier),2)==0
        czero_len=length(dlist_modifier)/2;
    else
        czero_len=floor(length(dlist_modifier)/2)+1;
    end

    if mod(firlen,2)==0
        partitionlen=firlen/2;
    else
        partitionlen=floor(firlen/2)+1;
    end

    fl.firlen=firlen;
    fl.coeff_len=coeff_len;
    fl.czero_len=czero_len;
    fl.partitionlen=partitionlen;
    fl.dalen=czero_len;

