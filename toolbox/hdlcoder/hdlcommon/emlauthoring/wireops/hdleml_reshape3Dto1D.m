%#codegen
function y=hdleml_reshape3Dto1D(outEx,u)


    coder.allowpcode('plain')
    coder.internal.allowHalfInputs
    eml_prefer_const(outEx);


    y=hdleml_define(outEx);

    dims_in=size(u);
    ii=1;
    for k=coder.unroll(1:dims_in(3))
        for j=coder.unroll(1:dims_in(2))
            for i=coder.unroll(1:dims_in(1))
                y(ii)=u(i,j,k);
                ii=ii+1;
            end
        end
    end
end


