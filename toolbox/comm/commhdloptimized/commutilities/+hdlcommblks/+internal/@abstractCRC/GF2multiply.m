function y=GF2multiply(~,A,B)







    [rowA,colA]=size(A);
    [~,colB]=size(B);

    y=false(rowA,colB);

    for j=1:colB
        for i=1:rowA
            t=false;
            for k=1:colA
                t=xor(t,and(A(i,k),B(k,j)));
            end
            y(i,j)=t;
        end
    end

end
