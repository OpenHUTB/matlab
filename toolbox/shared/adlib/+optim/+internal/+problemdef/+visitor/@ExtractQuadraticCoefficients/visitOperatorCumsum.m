function visitOperatorCumsum(visitor,op,Node)




    [~,~,HLeft]=popChild(visitor,1);


    visitOperatorCumsum@optim.internal.problemdef.visitor.ExtractLinearCoefficients(...
    visitor,op,Node);


    sz=op.InputSize;


    if prod(sz)==1
        Hval=HLeft;
        pushH(visitor,Hval);
        return
    end


    nVar=size(HLeft,2);


    if strcmp(op.Direction,"reverse")
        inputDir="forward";
    else
        inputDir="reverse";
    end

    CumHessOp=optim.problemdef.gradients.cumulative.CumulativeStencil(...
    sz,op.Dim,inputDir,nVar);


    Hval=CumHessOp*HLeft;
    pushH(visitor,Hval);

end
