%#codegen
function y=hdleml_reshape(outEx,u)


    coder.allowpcode('plain')
    coder.internal.allowHalfInputs
    eml_prefer_const(outEx);


    y=hdleml_define(outEx);

    dims_in=size(u);
    dims_out=size(y);

    rows_out=dims_out(1);
    cols_out=dims_out(2);
    ii=1;
    jj=1;

    for j=coder.unroll(1:dims_in(2))
        for i=coder.unroll(1:dims_in(1))
            y(ii,jj)=u(i,j);
            ii=ii+1;
            if(ii>rows_out)
                ii=1;
                jj=jj+1;
            end
        end
    end

end
