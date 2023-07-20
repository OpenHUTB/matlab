function compileUnaryOperatorZeroHandling(visitor,op,Node)






    leftAllZero=isChildAllZero(visitor,1);

    if leftAllZero

        pushAllZeros(visitor,size(Node));
    else
        compileUnaryOperator(visitor,op,Node);
    end

end
