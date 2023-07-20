function visitOperatorTimes(visitor,~,~)




    [bLeft,ALeft]=popChild(visitor,1);
    [bRight,ARight]=popChild(visitor,2);

    [Aval,bval]=extractLinearCoefficientsForTimes(ALeft,ARight,bLeft,bRight);


    push(visitor,Aval,bval);

end
