%#codegen
function y=hdleml_unaryminus(u,oType_ex)





    coder.allowpcode('plain')
    eml_prefer_const(oType_ex);

    if nargin<2
        oType_ex=u;
    end

    if isfloat(oType_ex)
        y=-u;
    else
        nt_u=numerictype(u);
        u_fm=fimath(u);

        if nt_u.WordLength==128

            fm=fimath(...
            'RoundMode',u_fm.RoundMode,...
            'OverflowMode',u_fm.OverflowMode,...
            'ProductMode','SpecifyPrecision',...
            'ProductWordLength',128,...
            'SumMode','SpecifyPrecision',...
            'SumWordLength',128,...
            'MaxSumWordLength',128,...
            'MaxProductWordLength',128);

            ut=fi(u,nt_u,fm);
        else

            ut=fi(u,numerictype(oType_ex),fimath(oType_ex));
        end
        y=fi(-ut,numerictype(oType_ex),fimath(oType_ex));
    end

