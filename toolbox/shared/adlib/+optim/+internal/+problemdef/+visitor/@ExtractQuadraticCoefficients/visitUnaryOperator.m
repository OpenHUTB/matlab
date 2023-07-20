function visitUnaryOperator(visitor,op,Node)




    [~,~,HLeft]=popChild(visitor,1);


    visitUnaryOperator@optim.internal.problemdef.visitor.ExtractLinearCoefficients(...
    visitor,op,Node);


    Hval=evaluate(op,HLeft,[],visitor);
    pushH(visitor,Hval);

end
