%#codegen
function y=hdleml_add(u,v,outtp_ex)





    coder.allowpcode('plain')
    coder.internal.allowHalfInputs
    eml_prefer_const(outtp_ex);

    if nargin<3
        outtp_ex=u;
    end

    if isfloat(outtp_ex)
        y=u+v;
    else
        nt_u=numerictype(u);
        nt_v=numerictype(v);

        if nt_u.WordLength+nt_v.WordLength>128

            nt_o=numerictype(outtp_ex);
            fm_o=fimath(outtp_ex);


            fm=fimath(...
            'RoundMode',fm_o.RoundMode,...
            'OverflowMode',fm_o.OverflowMode,...
            'ProductMode','FullPrecision',...
            'MaxProductWordLength',128,...
            'SumMode','SpecifyPrecision',...
            'SumWordLength',nt_o.WordLength,...
            'SumFractionLength',nt_o.FractionLength,...
            'MaxSumWordLength',128);

            ut=fi(u,nt_u,fm);
            vt=fi(v,nt_v,fm);

            y=fi(ut+vt,nt_o,fm_o);
        else

            y=fi(u+v,numerictype(outtp_ex),fimath(outtp_ex));
        end
    end
