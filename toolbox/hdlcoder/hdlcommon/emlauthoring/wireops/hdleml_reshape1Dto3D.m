%#codegen
function y=hdleml_reshape1Dto3D(outEx,u)


    coder.allowpcode('plain')
    coder.internal.allowHalfInputs
    eml_prefer_const(outEx);


    y=hdleml_define(outEx);

    dims_out=size(y);
    ii=1;
    for k=coder.unroll(1:dims_out(3))
        for j=coder.unroll(1:dims_out(2))
            for i=coder.unroll(1:dims_out(1))
                y(i,j,k)=u(ii);
                ii=ii+1;
            end
        end
    end
end


