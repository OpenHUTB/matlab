function visitOperatorPower(visitor,op,~)




    [bLeft,ALeft,HLeft]=popChild(visitor,1);

    exponent=getExponent(op,visitor);
    switch exponent
    case 0
        Hval=[];
        Aval=[];
        bval=ones(size(bLeft));
    case 1
        Hval=HLeft;
        Aval=ALeft;
        bval=bLeft;
    otherwise



        if nnz(ALeft)>0





            ALMat=columns2blkdiag(ALeft);
            Hval=ALMat*ALeft.';
            Aval=2.*ALeft.*bLeft.';
        else
            Hval=[];
            Aval=ALeft;
        end
        bval=bLeft.^2;
    end


    push(visitor,Aval,bval);
    pushH(visitor,Hval);

end
