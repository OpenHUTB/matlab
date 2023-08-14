function x=matrixDivision(A,B)%#codegen





    x=A\B;

    for idx=1:length(x)
        x(idx)=x(idx)+(x(idx)==0)*eps;
    end

end