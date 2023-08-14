%#codegen
function y=hdleml_3Dmatrixconst(outEx,cval)


    coder.allowpcode('plain')
    coder.internal.allowHalfInputs
    eml_prefer_const(outEx,cval);


    y=hdleml_define(outEx);
    sz=size(y);


    for ii=coder.unroll(1:sz(1))
        for jj=coder.unroll(1:sz(2))
            for kk=coder.unroll(1:sz(3))
                y(ii,jj,kk)=cval(ii,jj,kk);
            end
        end
    end
