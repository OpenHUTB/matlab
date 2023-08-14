function[x,y,z]=eml_al_cordic_rotation_hdl(xin,yin,zin,lut_value,idx)



%#codegen

    coder.allowpcode('plain');
    eml_prefer_const(lut_value);
    eml_prefer_const(idx);


    fm=fimath(lut_value);
    x0=fi(xin,fm);
    y0=fi(yin,fm);
    z0=fi(zin,fm);
    x1=coder.nullcopy(fi(x0,fm));
    y1=coder.nullcopy(fi(y0,fm));
    x=coder.nullcopy(fi(x0,fm));
    y=coder.nullcopy(fi(y0,fm));
    z=coder.nullcopy(fi(z0,fm));

    rt_shift=idx-1;
    y1(:)=bitsra(y0,rt_shift);
    x1(:)=bitsra(x0,rt_shift);

    if(z0<0)
        x(:)=x0+y1;
        y(:)=y0-x1;
        z(:)=z0+lut_value;
    else
        x(:)=x0-y1;
        y(:)=y0+x1;
        z(:)=z0-lut_value;
    end

end
