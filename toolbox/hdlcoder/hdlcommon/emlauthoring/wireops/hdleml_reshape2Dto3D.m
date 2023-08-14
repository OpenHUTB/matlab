%#codegen
function y=hdleml_reshape2Dto3D(outEx,u)


    coder.allowpcode('plain')
    coder.internal.allowHalfInputs
    eml_prefer_const(outEx);


    y=hdleml_define(outEx);

    dims_out=size(y);
    dims_in=size(u);

    ii=1;
    jj=1;
    for k=coder.unroll(1:dims_out(3))
        for j=coder.unroll(1:dims_out(2))
            for i=coder.unroll(1:dims_out(1))
                y(i,j,k)=u(ii,jj);
                ii=ii+1;
                if(ii>dims_in(1))
                    ii=1;
                    jj=jj+1;
                end
            end
        end
    end
end


