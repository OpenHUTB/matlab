function visitOperatorMpower(visitor,op,~)




    [bLeft,ALeft]=popChild(visitor,1);

    exponent=getExponent(op,visitor);

    switch exponent
    case 0
        Aval=[];
        N=sqrt(numel(bLeft));
        bval=eye(N);
        bval=bval(:);
    case 1
        Aval=ALeft;
        bval=bLeft;
    otherwise



        M=sqrt(numel(bLeft));
        b=reshape(bLeft,[M,M]);
        if nnz(ALeft)<1
            Aval=[];
        else
            kronMat=kron(b,speye(M))+kron(speye(M),b');
            Aval=ALeft*kronMat;
        end


        bval=b^(exponent);
        bval=bval(:);
    end


    push(visitor,Aval,bval);

end
