function visitElementwiseOperator(visitor,op,~)






    [bLeft,ALeft]=popChild(visitor,1);
    [bRight,ARight]=popChild(visitor,2);



    zeroALeft=nnz(ALeft)==0;
    zeroARight=nnz(ARight)==0;
    if zeroALeft
        if zeroARight
            Aval=[];
        else

            ARight=evaluate(op,sparse(0),ARight,visitor);
            if isscalar(bRight)
                Aval=repmat(ARight,1,numel(bLeft));
            else
                Aval=ARight;
            end
        end
    elseif zeroARight

        if isscalar(bLeft)
            Aval=repmat(ALeft,1,numel(bRight));
        else
            Aval=ALeft;
        end
    else

        Aval=evaluate(op,ALeft,ARight,visitor);
    end

    bval=evaluate(op,bLeft,bRight,visitor);


    push(visitor,Aval,bval);

end
