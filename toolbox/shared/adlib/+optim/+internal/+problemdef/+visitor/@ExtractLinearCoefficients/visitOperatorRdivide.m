function visitOperatorRdivide(visitor,~,~)








    [bLeft,ALeft]=popChild(visitor,1);
    [bRight,ARight]=popChild(visitor,2);

    [Aval,bval]=extractLinearCoefficientsForTimes(ALeft,ARight,bLeft,1./bRight);


    push(visitor,Aval,bval);

end
