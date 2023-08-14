function visitOperatorMtimes(visitor,op,~)




    [bLeft,ALeft]=popChild(visitor,1);
    [bRight,ARight]=popChild(visitor,2);



    zeroALeft=nnz(ALeft)<1;
    zeroARight=nnz(ARight)<1;

    if zeroALeft
        if zeroARight

            Aval=[];

            bval=reshape(bLeft,op.LeftSize)*reshape(bRight,op.RightSize);
            bval=bval(:);
        else


            [Aval,bval]=visitor.visitOperatorMtimesZeroALeft(op,bLeft,ARight,bRight);
        end
    else


        [Aval,bval]=visitor.visitOperatorMtimesZeroARight(op,ALeft,bLeft,bRight);
    end


    push(visitor,Aval,bval);

end
