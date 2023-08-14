function visitOperatorCumsum(visitor,op,~)




    [bLeft,ALeft]=popChild(visitor,1);


    sz=op.InputSize;


    if prod(sz)==1
        Aval=ALeft;
        bval=bLeft;

        push(visitor,Aval,bval);
        return;
    end


    CumLinOp=optim.problemdef.gradients.cumulative.CumulativeStencil(...
    sz,op.Dim,op.Direction,1);


    if~isempty(ALeft)
        Aval=ALeft*CumLinOp;
    else
        Aval=ALeft;
    end




    bval=(bLeft'*CumLinOp)';


    push(visitor,Aval,bval);

end
