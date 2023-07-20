%#codegen
function y=hdleml_inc_dec_si(u,mode)


    coder.allowpcode('plain')
    eml_prefer_const(mode);

    if isreal(u)
        y=inc_dec_si(u,mode);
    else
        u_r=inc_dec_si(real(u),mode);
        u_i=imag(u);
        y=complex(u_r,u_i);
    end

end

function y=inc_dec_si(u,mode)

    y=hdleml_define(u);

    if isfloat(u)
        if(mode==1)
            y=u+1;
        else
            y=u-1;
        end
    elseif isfi(u)
        fm=hdlfimath;
        nt=numerictype(u);
        nt2=numerictype(nt.Signed,nt.WordLength,0);
        if(mode==1)
            t=fi(hdleml_add(reinterpretcast(u,nt2),fi(1,nt2,fm)),nt2,fm);
            y=reinterpretcast(t,nt);
        else
            t=fi(hdleml_sub(reinterpretcast(u,nt2),fi(1,nt2,fm)),nt2,fm);
            y=reinterpretcast(t,nt);
        end
    end

end
