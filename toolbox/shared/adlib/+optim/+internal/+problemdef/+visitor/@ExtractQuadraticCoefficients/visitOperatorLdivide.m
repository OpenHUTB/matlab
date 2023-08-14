function visitOperatorLdivide(visitor,~,~)








    [bLeft,ALeft,HLeft]=popChild(visitor,1);
    [bRight,ARight,HRight]=popChild(visitor,2);

    [Hval,Aval,bval]=extractQuadraticCoefficientsForTimes(...
    HLeft,HRight,ALeft,ARight,1./bLeft,bRight);


    push(visitor,Aval,bval);
    pushH(visitor,Hval);

end
