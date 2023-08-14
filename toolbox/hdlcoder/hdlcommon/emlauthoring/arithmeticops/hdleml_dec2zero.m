%#codegen
function y=hdleml_dec2zero(u)


    coder.allowpcode('plain')

    y=hdleml_define(u);
    outLen=length(u);

    if isfloat(u)
        for ii=coder.unroll(1:outLen)
            if(u(ii)>1)
                y(ii)=u(ii)-1;
            else
                y(ii)=0;
            end
        end
    else
        nt=numerictype(u);
        fm=hdlfimath;

        one=fi(1,nt,fm);
        zero=fi(0,nt,fm);

        for ii=coder.unroll(1:outLen)
            if(u(ii)>1)
                y(ii)=fi(u(ii)-one,nt,fm);
            else
                y(ii)=zero;
            end
        end
    end

end