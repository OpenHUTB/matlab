function dalut=getDALUTforwidth(this,width)







    fl=this.getfilterlengths;
    taps=fl.czero_len;
    nwidth=floor(taps/width);
    if mod(taps,width)~=0
        dalut=[ones(1,nwidth)*width,rem(taps,width)];
    else
        dalut=ones(1,nwidth)*width;
    end
