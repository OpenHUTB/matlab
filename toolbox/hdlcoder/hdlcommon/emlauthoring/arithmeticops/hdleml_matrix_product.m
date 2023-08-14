%#codegen
function y=hdleml_matrix_product(u,v,outtp_ex,useFullPrecision)







    coder.allowpcode('plain')
    eml_prefer_const(outtp_ex);
    eml_prefer_const(useFullPrecision)
    if nargin<3
        outtp_ex=u;
    end

    if nargin<4
        useFullPrecision=0;
    end

    if isfloat(outtp_ex)
        y=u*v;
    else
        nt_u=numerictype(u);
        nt_v=numerictype(v);

        nt_o=numerictype(outtp_ex);
        fm_o=fimath(outtp_ex);

        if nt_u.WordLength+nt_v.WordLength>128

            fm=fimath(...
            'RoundMode',fm_o.RoundMode,...
            'OverflowMode',fm_o.OverflowMode,...
            'ProductMode','SpecifyPrecision',...
            'ProductWordLength',nt_o.WordLength,...
            'ProductFractionLength',nt_o.FractionLength,...
            'MaxProductWordLength',128,...
            'SumMode','FullPrecision',...
            'MaxSumWordLength',128);

            ut=fi(u,nt_u,fm);
            vt=fi(v,nt_v,fm);

            if useFullPrecision
                y=ut*vt;
            else
                y=fi(ut*vt,numerictype(outtp_ex),fimath(outtp_ex));
            end
        else

            if useFullPrecision
                y=u*v;
            else
                if isscalar(u)||isscalar(v)
                    y=hdleml_product(u,v,outtp_ex);
                else
                    y=domatrixproduct(u,v,outtp_ex);
                end
            end
        end
    end
end




function matrixProductout=domatrixproduct(u,v,outtp_ex)
    [m,~]=size(u);
    [p,n]=size(v);

    if isreal(u)&&isreal(v)
        C=fi(zeros(m,n),numerictype(outtp_ex),fimath(outtp_ex));
    else
        C=complex(fi(zeros(m,n),numerictype(outtp_ex),fimath(outtp_ex)));
    end

    for i=1:m
        for j=1:n
            for k=1:p
                prodOut=hdleml_product(u(i,k),v(k,j),outtp_ex);
                C(i,j)=fi(C(i,j)+prodOut,numerictype(outtp_ex),fimath(outtp_ex));
            end
        end
    end
    matrixProductout=C;
end


