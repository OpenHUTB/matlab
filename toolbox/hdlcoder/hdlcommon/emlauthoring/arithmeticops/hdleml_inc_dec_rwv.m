%#codegen
function y=hdleml_inc_dec_rwv(u,mode)


    coder.allowpcode('plain')
    eml_prefer_const(mode);

    if isreal(u)
        y=inc_dec_rwv(u,mode);
    else
        u_r=inc_dec_rwv(real(u),mode);
        u_i=imag(u);
        y=complex(u_r,u_i);
    end

end

function y=inc_dec_rwv(u,mode)

    y=hdleml_define(u);

    if isfloat(u)
        if(mode==1)
            y=u+1;
        else
            y=u-1;
        end
    elseif isfi(u)
        nt=numerictype(u);
        fm=hdlfimath;

        fm_sl=fimath(...
        'RoundMode','nearest',...
        'OverflowMode','saturate',...
        'ProductMode','FullPrecision',...
        'ProductWordLength',128,...
        'SumMode','FullPrecision',...
        'SumWordLength',128);
        one_sl=fi(1,nt,fm_sl);

        one=fi(one_sl,nt,fm);

        if(mode==1)
            y=hdleml_add(u,one);
        else
            y=hdleml_sub(u,one);
        end
    end

end
