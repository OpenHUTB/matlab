function[yout,xout]=eml_al_cordic_sincos(angle,lut_values,num_iters,K)



%#codegen




    coder.allowpcode('plain');
    eml_prefer_const(lut_values,K,num_iters);


    [x0,y0,xout,yout]=cordic_init(angle,lut_values,K);


    if isfloat(angle)
        fm='';
        lut_values2=lut_values;
    else
        opType=eml_al_numerictype(K);
        fm=eml_al_cordic_fimath(lut_values);
        lut_values2=fi(lut_values,opType,fm);
    end

    for j=1:numel(angle)

        if isfloat(angle)
            theta=angle(j);
            [negate,z0]=eml_al_cordic_quad_correction_before_float(theta);
        else
            theta=fi(angle(j),eml_al_numerictype(angle),fm);
            K2=fi(K,eml_al_numerictype(K),fm);
            [negate,z0]=eml_al_cordic_quad_correction_before(theta,K2);
        end


        [xn,yn]=eml_al_cordic_kernel_loop(x0,y0,z0,lut_values2,num_iters);


        [xout(j),yout(j)]=eml_al_cordic_quad_correction_after(xn,yn,negate);
    end

end


function[x0,y0,xout,yout]=cordic_init(angle,lut_values,K)



    if isa(angle,'double')
        x0=double(K);
        y0=0.0;
        xout=coder.nullcopy(zeros(size(angle)));
        yout=coder.nullcopy(zeros(size(angle)));
    elseif isa(angle,'single')
        x0=single(K);
        y0=single(0.0);
        xout=coder.nullcopy(single(zeros(size(angle))));
        yout=coder.nullcopy(single(zeros(size(angle))));
    else
        fm=eml_al_cordic_fimath(lut_values);
        opType=eml_al_numerictype(K);

        x0=fi(K,opType,fm);
        y0=fi(0,opType,fm);

        xout=coder.nullcopy(fi(zeros(size(angle)),opType,fm));
        yout=coder.nullcopy(fi(zeros(size(angle)),opType,fm));
    end
end


