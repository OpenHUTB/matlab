%#codegen
function y=hdleml_product(u,v,outtp_ex,useFullPrecision)







    coder.allowpcode('plain')
    coder.internal.allowHalfInputs
    eml_prefer_const(outtp_ex,useFullPrecision);
    if nargin<3
        outtp_ex=u;
    end

    if nargin<4
        useFullPrecision=0;
    end

    if isfloat(outtp_ex)
        y=u.*v;
    else
        nt_u=numerictype(u);
        nt_v=numerictype(v);

        if nt_u.WordLength+nt_v.WordLength>128

            nt_o=numerictype(outtp_ex);
            fm_o=fimath(outtp_ex);


            prodWidth=computeProductWidth(nt_u,nt_v,nt_o);
            fm=fimath(...
            'RoundMode',fm_o.RoundMode,...
            'OverflowMode',fm_o.OverflowMode,...
            'ProductMode','SpecifyPrecision',...
            'ProductWordLength',prodWidth,...
            'ProductFractionLength',nt_o.FractionLength,...
            'MaxProductWordLength',128,...
            'SumMode','FullPrecision',...
            'MaxSumWordLength',128);


            ut=fi(u,nt_u,fm);
            vt=fi(v,nt_v,fm);
            y=doprod(ut,vt,outtp_ex,useFullPrecision);
        else

            y=doprod(u,v,outtp_ex,useFullPrecision);
        end
    end
end

function prodWidth=computeProductWidth(nt_u,nt_v,nt_o)
    eml_prefer_const(nt_o);
    if~nt_o.SignednessBool&&(nt_u.SignednessBool||nt_v.SignednessBool)



        prodWidth=nt_o.WordLength+1;
        if prodWidth>128
            prodWidth=128;
        end
    else
        prodWidth=nt_o.WordLength;
    end
end

function y=doprod(u,v,outtp_ex,useFullPrecision)
    eml_prefer_const(outtp_ex,useFullPrecision);

    if useFullPrecision
        y=u.*v;
    else
        if isreal(u)
            y=fi(u.*v,numerictype(outtp_ex),fimath(outtp_ex));
        else
            y=product_complex(u,v,outtp_ex);
        end
    end
end

function y=product_complex(u,v,outtp_ex)



    eml_prefer_const(outtp_ex);

    nt=numerictype(outtp_ex);
    fm=fimath(outtp_ex);
    mul_temp=fi(real(u).*real(v),nt,fm);
    mul_temp_1=fi(imag(u).*imag(v),nt,fm);
    y_re=hdleml_sub_withcast(mul_temp,mul_temp_1,outtp_ex,outtp_ex,1);

    mul_temp_2=fi(imag(u).*real(v),nt,fm);
    mul_temp_3=fi(real(u).*imag(v),nt,fm);

    y_im=hdleml_add_withcast(mul_temp_2,mul_temp_3,outtp_ex,outtp_ex,1);
    y=complex(y_re,y_im);
end
