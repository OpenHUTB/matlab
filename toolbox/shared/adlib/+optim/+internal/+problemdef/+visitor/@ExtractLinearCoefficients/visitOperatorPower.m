function visitOperatorPower(visitor,op,~)




    [bLeft,ALeft]=popChild(visitor,1);

    exponent=getExponent(op,visitor);
    switch exponent
    case 0
        Aval=[];
        bval=ones(size(bLeft));
    case 1
        Aval=ALeft;
        bval=bLeft;
    otherwise


        Aval=[];


        bval=bLeft.^(exponent);
    end


    push(visitor,Aval,bval);

end
