function y=vecToSymMat(in,n,ntri)
%#codegen



    if n==1
        y=in;
    else
        d=in(1:ntri);
        y=zeros(n);
        upperTriangleIndices=triu(true(n));
        y(upperTriangleIndices)=d;
        y=y+y.'-diag(diag(y));

    end
end

