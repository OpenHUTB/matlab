function[xout,yout]=eml_al_cordic_quad_correction_after(x,y,negate)



%#codegen

    coder.allowpcode('plain')

    xout=coder.nullcopy(x);
    yout=coder.nullcopy(y);

    if negate
        xout(:)=-x;
        yout(:)=-y;
    else
        xout(:)=x;
        yout(:)=y;
    end
end
