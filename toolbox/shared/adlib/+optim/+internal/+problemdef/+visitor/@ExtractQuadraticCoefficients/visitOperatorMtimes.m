function visitOperatorMtimes(visitor,op,~)




    [bLeft,ALeft,HLeft]=popChild(visitor,1);
    [bRight,ARight,HRight]=popChild(visitor,2);


    M=op.LeftSize(1);
    K=op.LeftSize(2);
    P=op.RightSize(2);

    zeroALeft=nnz(ALeft)<1;
    zeroHLeft=nnz(HLeft)<1;
    zeroARight=nnz(ARight)<1;
    zeroHRight=nnz(HRight)<1;


    if zeroHLeft
        if zeroHRight


            Hval=[];
        else

















            N=size(HRight,2);
            kronMat=kron(speye(P),kron(reshape(bLeft,[M,K]),eye(N)));
            Hval=kronMat*HRight;
        end
    elseif zeroHRight












        N=size(HLeft,2);
        kronMat=kron(reshape(bRight,[K,P])',speye(M*N));
        Hval=kronMat*HLeft;
    end


    if zeroALeft
        if zeroARight


            Aval=[];

            bval=reshape(bLeft,[M,K])*reshape(bRight,[K,P]);
            bval=bval(:);
        else

            [Aval,bval]=visitor.visitOperatorMtimesZeroALeft(op,bLeft,ARight,bRight);
        end
    elseif zeroARight

        [Aval,bval]=visitor.visitOperatorMtimesZeroARight(op,ALeft,bLeft,bRight);
    else

        N=size(ALeft,1);
        Hval=kron(speye(P),reshape(ALeft,[N*M,K]))*ARight';


        kronMat=kron(reshape(bRight,[K,P]),speye(M));
        Aval=ALeft*kronMat;
        kronMat=kron(speye(P),reshape(bLeft,[M,K])');
        Aval=Aval+ARight*kronMat;
        bval=bRight'*kronMat;
        bval=bval(:);
    end


    push(visitor,Aval,bval);
    pushH(visitor,Hval);

end
