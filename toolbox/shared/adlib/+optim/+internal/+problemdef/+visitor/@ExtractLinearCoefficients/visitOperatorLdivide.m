function visitOperatorLdivide(visitor,~,~)








    [bLeft,ALeft]=popChild(visitor,1);
    [bRight,ARight]=popChild(visitor,2);

    [Aval,bval]=extractLinearCoefficientsForTimes(ALeft,ARight,1./bLeft,bRight);


    push(visitor,Aval,bval);

end
