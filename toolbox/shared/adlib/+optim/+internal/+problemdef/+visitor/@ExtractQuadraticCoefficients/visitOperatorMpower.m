function visitOperatorMpower(visitor,op,Node)




    [HLeft,ALeft]=popChild(visitor,1);


    visitOperatorMpower@optim.internal.problemdef.visitor.ExtractLinearCoefficients(...
    visitor,op,Node);












    exponent=getExponent(op,visitor);
    switch exponent
    case 0
        Hval=[];
    case 1
        Hval=HLeft;
    otherwise




        [N,M2]=size(ALeft);
        M=sqrt(M2);
        Hval=kron(speye(M),reshape(ALeft,[N*M,M]))*ALeft';
    end


    pushH(visitor,Hval);

end
