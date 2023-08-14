%#codegen
function y=hdleml_abs(u,outtp_ex)

    coder.allowpcode('plain')
    eml_prefer_const(outtp_ex);

    if isfi(u)
        nt_u=numerictype(u);
        nt=numerictype(nt_u.SignednessBool,nt_u.WordLength+1,nt_u.FractionLength);
        yt=abs(u,nt,fimath(outtp_ex));
        y=fi(yt,numerictype(outtp_ex),fimath(outtp_ex));
    elseif isfloat(u)
        y=hdleml_define(u);
        for ii=0:numel(u)
            if u(ii)<0
                y(ii)=-u(ii);
            else
                y(ii)=u(ii);
            end
        end
    else
        eml_assert;
    end
